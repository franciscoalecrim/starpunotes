#!/bin/bash

# StarPU --- Runtime system for heterogeneous multicore architectures.
#
# Copyright (C) 2012, 2014  CNRS
#
# StarPU is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; either version 2.1 of the License, or (at
# your option) any later version.
#
# StarPU is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# See the GNU Lesser General Public License in COPYING.LGPL for more details.

export | grep STARPU

SLEEP_SECS=20

if [[ ! -v STARPU_PATH ]]; then
    echo "Environment variables are not set. Use starpu_env.sh "
    exit 1
elif [[ -z "$STARPU_PATH" ]]; then
    echo "Environment variables are not set. Use starpu_env.sh "
    exit 1
else
    echo "STARPU_PATH has the value: $STARPU_PATH"
fi


i=1 ; while [ -d result$i ]; do i=$((i+1)) ; done; 
export OUTPUTFOLDER="result$i"
/bin/mkdir $OUTPUTFOLDER
echo "Results to folder: $OUTPUTFOLDER"

date

check_success()
{
	if [ $1 -ne 0 ] ; then
		echo "failure" >&2
		exit $1
	fi
}

DATETIMES=`date +%Y%m%d%H%M%S`
APPLICATIONS=`cat applications.in`
for APP in $APPLICATIONS
do
        APP="$STARPU_EXAMPLES_DIR/$APP"
	BASE=`basename $APP`
	SCHEDULERS=`cat schedulers.in`
	for sched in $SCHEDULERS
	do
		FREQUENCIES=`cat frequencies.in`
		for FREQ in $FREQUENCIES
		do

			CORETYPES=`cat coretypes.in`
			for CORETYPE in $CORETYPES
			do	
				sleep $SLEEP_SECS
				date
				PROFILE="$CORETYPE"_"$sched"_"$BASE"_"$FREQ"
				echo $PROFILE
				rm  /tmp/prof_file_${USER}_0 > /dev/null 2>&1

				# CORE TYPE
				. ./$STARPU_CONFIG_FOLDER/$CORETYPE

				# FREQUENCY TYPE 
				bash ./$STARPU_CONFIG_FOLDER/$FREQ >> "$DATETIMES"_"$PROFILE"_log.info
								
				# START METRICS
				bash $PWD/metrics.sh $PROFILE $DATETIMES & 
				
				# SCHED AND EXECUTE APP
				export | grep STARPU
				STARPU_SCHED="$sched" "$APP"
				check_success $?
				
				# STOP METRICS
				rm -f /tmp/metrics.tmp

				# SAVE RESULTS
				sleep 1 
				$STARPU_PATH/bin/starpu_fxt_tool -i /tmp/prof_file_${USER}_0
				mv /tmp/prof_file_${USER}_0 "$OUTPUTFOLDER"/"$DATETIMES"_profile_"$PROFILE"
				mv paje.trace "$OUTPUTFOLDER"/"$DATETIMES"_paje_"$PROFILE".trace
				mv *.log "$OUTPUTFOLDER"/.
				mv *_log.info "$OUTPUTFOLDER"/.
				date

				#clean up
				rm -f activity.data dag.dot data.rec distrib.data tasks.rec trace.html trace.rec
			done
		done
	done
done
date

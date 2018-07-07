#!/bin/bash

export | grep STARPU

if [[ ! -v STARPU_PATH ]]; then
    echo "Environment variables are not set. Use starpu_env.sh "
    exit 1
elif [[ -z "$STARPU_PATH" ]]; then
    echo "Environment variables are not set. Use starpu_env.sh "
    exit 1
else
    echo "STARPU_PATH has the value: $STARPU_PATH"
fi

check_success()
{
	if [ $1 -ne 0 ] ; then
		echo "failure" >&2
		xset dpms force on
		while true ; do echo "test finished" | festival --tts ; done 
	fi
}


#while battery 
while true ; do 

SLEEP_SECS=20
BATLEVEL=`cat /sys/class/power_supply/BAT0/uevent | grep POWER_SUPPLY_CAPACITY | head -n1 | cut -f2 -d=`
CHARGING=`cat /sys/class/power_supply/BAT0/uevent | grep Charging | wc -l`
if [ $BATLEVEL -le 25 -o $CHARGING -gt 0 ] ; then 
	echo "Battery is too low or charing";
	xset dpms force on
	while true ; do echo "test finished" | festival --tts ; done 
fi


#Create log dir
rm *.log -rf *.csv
i=1 ; while [ -d result$i ]; do i=$((i+1)) ; done; 
export OUTPUTFOLDER="result$i"
/bin/mkdir $OUTPUTFOLDER
echo "Results to folder: $OUTPUTFOLDER"
date
sudo echo "teste password"
echo "waiting screen power off" | festival --tts
#esperando tela apagar
date | mail -s 'teste iniciado' alecrim@gmail.com 
sleep 2
nmcli n off
sleep 3
xset dpms force off
echo "starting tests with screen off" | festival --tts
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
				echo "starting test" | festival --tts
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
date;

nmcli n off
sleep 10
date | mail -s 'teste finalizado' alecrim@gmail.com 

done 

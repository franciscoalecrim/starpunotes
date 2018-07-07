#!/bin/bash

DATETIMES=`date +%Y%m%d%H%M%S`
RESULTDIR="./"$(ls | grep result | tail -n1)"/"
RESULTFILE="compiled_result.csv"

function process_profile {
	PROFILE=$1 
	BASE=$2
	echo $PROFILE
	for file in `/bin/ls $RESULTDIR | grep $PROFILE | grep '\.log' | tail -n1`
	do
		echo $file
		#TIME
		time_initial=$(/bin/grep "BEGIN DATE SECONDS" "$RESULTDIR""$file" | head -n1 | cut -f4 -d" ")
		time_final=$(/bin/grep "END DATE SECONDS" "$RESULTDIR""$file" | tail -n1 | cut -f4 -d" ")
		time_total=$(expr $time_final - $time_initial)

		#ENERGY
		#POWER_SUPPLY_CURRENT_NOW WATTS
		#POWER_SUPPLY_CHARGE_NOW microAmpere
		#W --- > current_now * voltage_now * 1e-12 = 8.25
		#(POWER_SUPPLY_CHARGE_FULL-POWER_SUPPLY_CHARGE_NOW)/P_SUPPLY_CURRENT_NOW
		sourceFile="$RESULTDIR""$file"
		
		energy_charge_initial=$(/bin/grep "POWER_SUPPLY_ENERGY_NOW" "$sourceFile" | head -n1 | cut -f2 -d"=")
		energy_charge_final=$(/bin/grep "POWER_SUPPLY_ENERGY_NOW" "$sourceFile" | tail -n1 | cut -f2 -d"=")
		energy_total=$(expr $energy_charge_initial - $energy_charge_final)
		echo "$PROFILE,$time_total,$energy_total" >> "compiled_result_$BASE.csv"
		echo "$PROFILE,$time_total,$energy_total" >> $RESULTFILE
		
	done
}  

######### MAIN ############

echo "profile,time_s,energy_mWh" > $RESULTFILE
APPLICATIONS=`cat applications.in`
for APP in $APPLICATIONS
do 
	BASE=`basename $APP`
	SCHEDULERS=`cat schedulers.in`
	echo "profile,time_s,energy_mWh" >  "compiled_result_$BASE.csv"
	for sched in $SCHEDULERS
	do
		FREQUENCIES=`cat frequencies.in`
		for FREQ in $FREQUENCIES
		do

			CORETYPES=`cat coretypes.in`
			for CORETYPE in $CORETYPES
			do
				PROFILE="$CORETYPE"_"$sched"_"$BASE"_"$FREQ"
				process_profile $PROFILE $BASE	
			done
		done
	done
done

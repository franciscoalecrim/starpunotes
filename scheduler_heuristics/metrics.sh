
DATE=$2
FILE="$DATE""_metrics_""$1"".log"

function gpu_util {
	gpulist=`nvidia-settings -t -q gpus`
	gpulist=`echo "$gpulist" | sed -e 's/^ *//'` # no leading spaces
	gpulist=`echo "$gpulist" | grep -e '^\['`

	echo $gpulist | while read LINE; do
	gpuid=`echo "$LINE" | cut -d \  -f 2 | grep -E -o '\[.*\]'`
	gpuname=`echo "$LINE" | cut -d \  -f 3-`

	gpuutilstats=`nvidia-settings -t -q "$gpuid"/GPUUtilization | tr ',' '\n'`
	gputemp=`nvidia-settings -t -q "$gpuid"/GPUCoreTemp`
	gputotalmem=`nvidia-settings -t -q "$gpuid"/TotalDedicatedGPUMemory`
	gpuusedmem=`nvidia-settings -t -q "$gpuid"/UsedDedicatedGPUMemory`

	gpuusage=`echo "$gpuutilstats"|grep graphics|sed 's/[^0-9]//g'`
	memoryusage=`echo "$gpuutilstats"|grep memory|sed 's/[^0-9]//g'`
	bandwidthusage=`echo "$gpuutilstats"|grep PCIe|sed 's/[^0-9]//g'`

	echo "$gpuid $gpuname" >> $FILE
	echo -e "\tRunning at : $gpuusage%" >> $FILE
	echo -e "\tCurrent temperature : $gputemp°C" >> $FILE
	echo -e "\tMemory usage : $gpuusedmem MB/$gputotalmem MB" >> $FILE
	echo -e "\tMemory bandwidth usage : $memoryusage%" >> $FILE
	echo -e "\tPCIe bandwidth usage : $bandwidthusage%" >> $FILE

done

}




function collect {
	#PERFORMANCE
	echo "BEGIN DATE `date`" >> $FILE
	echo "BEGIN DATE SECONDS `date +%s`" >> $FILE
	cpupower frequency-info >> $FILE
	#ENERGY
	cat /sys/class/power_supply/BAT0/* 2> /dev/null >> $FILE
	#TEMPERATURE
	sensors >> $FILE
	gpu_util >> $FILE
	echo "END DATE SECONDS `date +%s`" >> $FILE
	echo "END DATE `date`" >> $FILE
}


################################# MAIN ##################################
LOOP_FILE=/tmp/metrics.tmp
echo "delete $LOOP_FILE to stop me."
touch $LOOP_FILE
while [ -f $LOOP_FILE ] ;
do
	collect 
	sleep 1
done
echo "Log: $FILE" 

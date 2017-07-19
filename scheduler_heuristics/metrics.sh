
DATE=$2
FILE="$DATE""_metrics_""$1"".log"


function collect {
	#PERFORMANCE
	echo "BEGIN DATE `date`" >> $FILE
	echo "BEGIN DATE SECONDS `date +%s`" >> $FILE
	echo "END DATE SECONDS `date +%s`" >> $FILE
	echo "END DATE `date`" >> $FILE
	#ENERGY
	cat /sys/class/power_supply/BAT*/* 2> /dev/null >> $FILE
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

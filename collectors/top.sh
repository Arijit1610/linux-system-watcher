#!/bin/bash
source  /opt/watcher/config.cfg

if [[ $UID -gt 0 ]]
then
	echo "please run this {0} script as root user "
	exit 1

fi

while true
do
	sleep $INTERVAL
	time=$(date "+%d-%m-%y_%H-00-00")
	mkdir -p $path/wttop
	toppath="$path/wttop/top_output_$time.dat"
	echo "***** $(date) *****" >> $toppath
	top -b -n 1 -c  | head -30 >>$toppath

done

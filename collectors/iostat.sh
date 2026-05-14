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
        mkdir -p $path/wtiostat
        iostatpath="$path/wtiostat/iostat_output_$time.dat"
        echo "***** $(date) *****" >> $iostatpath
        iostat -x 1 3 >>$iostatpath

done


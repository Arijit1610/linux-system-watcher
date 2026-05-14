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
        mkdir -p $path/wtvmstat
        vmstatpath="$path/wtvmstat/vmstat_output_$time.dat"
        echo "***** $(date) *****" >> $vmstatpath
        vmstat >>$vmstatpath

done


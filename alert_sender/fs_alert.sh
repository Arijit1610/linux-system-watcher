#!/bin/bash

###Bash Script for monitoring File System Utlization and sending email to notify
source /opt/watcher/config.cfg
STATE_DIR="/tmp/fs_alert"
logfile="$LOG/alertlogger_fs.log"
mkdir -p "$STATE_DIR"
while true
do
	df -h| grep -vEi "mount|tmpfs" | while read -r line
	do
		usage=$(echo "$line"| awk '{print $5}'|sed 's/%//')
		mount=$(echo "$line"| awk '{print $6}')
		state_file="$STATE_DIR/$(echo "$mount"|tr '/' '_').state"
		if [[ "$usage" -ge "$FS_ALERT_THRESHOLD" && ! -f "$state_file" ]]
		then
			echo "Alert: $mount usage is ${usage}%" >> "$logfile"
			#send mail
			printf "ALERT: High Disk Usage Alert\n\nServer: %s\nMount: %s\nUsage: %s%%\nTime: %s\n" "$(hostname)" "$mount" "$usage" "$(date)" | mail -s "$(hostname): Disk Usage Alert" "$EMAIL"
			touch "$state_file"
		fi
		if [[ "$usage" -le "$FS_CLEAR_THRESHOLD" &&  -f "$state_file" ]]
		then
			echo "Alert Clear: $mount usage is ${usage}%" >> "$logfile"
			#send recovery mail
			printf "RECOVERY: Disk Usage Back to Normal\n\nServer: %s\nMount: %s\nUsage: %s%%\nTime: %s\n" "$(hostname)" "$mount" "$usage" "$(date)" | mail -s "$(hostname): Disk Usage Recovery" "$EMAIL"
			rm -f "$state_file" 
		fi 
	done
	sleep 300
done


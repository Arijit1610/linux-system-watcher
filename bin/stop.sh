#!/bin/bash

BASE="/root/watcher"
LOG="$BASE/logs/watcher.log"
LOCK="$BASE/bin/.startfile"

# Root check
if [[ $UID -ne 0 ]]; then
    echo "Run as root"
    exit 1
fi

# Prevent multiple runs
if [[ -f "$LOCK" ]]; then
    	echo -n "Stopping watcher.."
else
	echo "Watcher is not running"
	exit 1
fi

shopt -s nullglob

for file in "$BASE"/collectors/*.pid
do
	echo -n "."
	sleep 1

	pid=$(cat "$file" 2>$LOG)
	if [[ -n "$pid" ]]; 
	then 
		kill -9 "$pid" >>"$LOG" 2>&1 
		if [[ $? -ne 0 ]]; 
		then 
			echo " Failed to kill PID $pid" >>"$LOG" 
			exit 1 
		fi 
	fi

	rm -f "$file" 
done
echo "stoping archive process"
pid=$(cat "$BASE/archive/archive.pid" 2>$LOG)
if [[ -n "$pid" ]];
then
	kill -9 "$pid" >>"$LOG" 2>&1
        if [[ $? -ne 0 ]];
        then
        	echo " Failed to kill PID $pid" >>"$LOG"
                exit 1
        fi
fi
sleep 1

rm -f $BASE/archive/archive.pid

echo ""

rm -f "$LOCK"

echo "Watcher stopped Successfully"

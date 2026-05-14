#!/bin/bash
source /opt/watcher/config.cfg
logfile="$LOG/watcher.log"
#LOCK="$BASE/bin/.startfile"

/usr/bin/mkdir -p $LOG

# Root check
if [[ $UID -ne 0 ]]; then
    echo "Run as root"
    exit 1
fi

# Prevent multiple runs
#uncommment if not running as system process
#if [[ -f "$LOCK" ]]; then
#    echo "Watcher already running, cannot start"
#    exit 1
#else
#    touch "$LOCK"
#fi

echo "Starting watcher at $(/usr/bin/date)" >> "$logfile"

# Start collectors
bash $BASE/collectors/top.sh >> "$logfile" 2>&1 &
echo "starting collection of top" >> "$logfile"
echo $! > $BASE/collectors/top.pid

bash $BASE/collectors/vmstat.sh >> "$logfile" 2>&1 &
echo "starting collection of vmstat" >> "$logfile"
echo $! > $BASE/collectors/vmstat.pid

bash $BASE/collectors/iostat.sh >> "$logfile" 2>&1 &
echo "starting collection of iostat" >> "$logfile"
echo $! > $BASE/collectors/iostat.pid

bash $BASE/collectors/free.sh >> "$logfile" 2>&1 &
echo "starting collection of free" >> "$logfile"
echo $! > $BASE/collectors/free.pid

bash $BASE/collectors/df.sh >> "$logfile" 2>&1 &
echo "starting collection of df" >> "$logfile"
echo $! > $BASE/collectors/df.pid

bash $BASE/archive/archive.sh >> "$logfile" 2>&1 &
echo "starting archiving script" >> "$logfile"
echo $! > $BASE/archive/archive.pid

##ALERT SCRIPT##

bash $BASE/alert_sender/cpu_alert.sh >> "$logfile" 2>&1 &
echo "starting cpu alert script" >> "$logfile"

bash $BASE/alert_sender/memory_alert.sh >> "$logfile" 2>&1 &
echo "starting memory alert script" >> "$logfile"

bash $BASE/alert_sender/fs_alert.sh >> "$logfile" 2>&1 &
echo "starting filesystem alert script" >> "$logfile"



wait

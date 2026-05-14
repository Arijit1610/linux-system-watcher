#!/bin/bash
#High Memory usage alert
# ================================
# Configuration
# ================================
source /opt/watcher/config.cfg

logfile="$LOG/alertlogger_memory.log"

alert_sent=0        # 0 = no active alert, 1 = alert already sent
occurrence=0        # Counter to avoid false alerts (debounce)

# ================================
# Infinite monitoring loop
# ================================

memory_total=$(free | awk '/Mem/ {print $2}')
while true
do
    # Get memory usage percentage using free
    memory_used=$(free  | awk '/Mem/ {print $3}')
    # Calculate memory usage (100 - idle)
	memory_usage=$(( (memory_used * 100) / memory_total ))
    #echo "scale=2; ($memory_usage/$memory_total)*100" | bc
    # ================================
    # Debounce Logic
    # ================================
    # Increase occurrence only if:
    # 1. memory is above threshold AND alert not sent yet
    # 2. memory is below threshold AND alert already sent (for recovery)
    # Otherwise reset counter

    if [[ $memory_usage -gt $threshold && $alert_sent -eq 0 ]]
    then
	echo "MEMORY ALERT: $(date) ---> usage: $memory_usage" >> "$logfile"
        ((occurrence++))
    elif [[ $memory_usage -lt $threshold && $alert_sent -eq 1 ]]
    then
	echo "MEMORY ALERT: $(date) ---> usage: $memory_usage" >> "$logfile"
        ((occurrence++))
    else
	echo "MEMORY ALERT: $(date) ---> usage: $memory_usage" >> "$logfile"
        occurrence=0   # reset if condition breaks
    fi

    # ================================
    # High memory Alert Trigger
    # ================================
    if [[ $memory_usage -gt $threshold && $alert_sent -eq 0 && $occurrence -ge $max_occurrence ]]
    then
        alert_sent=1
        occurrence=0
	echo "MEMORY ALERT SENT: $(date) ---> usage: $memory_usage" >> "$logile"
        top_process=$(ps -eo pid,ppid,cmd,%mem --sort=-%mem | head -n 11)
        printf "ALERT: memory Usage Alert\nServer: %s\nUsage: %s%%\nTime: %s\n \nTop Process: \n%s\n " "$(hostname)" "$memory_usage" "$(date)" "$top_process" | mail -s "$(hostname):High memory sage Alert" "$EMAIL"
    fi

    # ================================
    # Recovery Alert (memory back to normal)
    # ================================
    if [[ $memory_usage -lt $threshold && $alert_sent -eq 1 && $occurrence -ge $max_occurrence ]]
    then
        alert_sent=0
        occurrence=0
	echo "MEMORY ALERT CLEAR: $(date) ---> usage: $memory_usage" >> "$logfile"
        printf "ALERT Clear: memory usage under threshold.\nServer: %s\nUsage: %s%%\nTime: %s\n" "$(hostname)" "$memory_usage" "$(date)" | mail -s "$(hostname): memory Alert clear" "$EMAIL"

    fi

    # ================================
    # Sleep before next check
    # ================================
    sleep 10
done


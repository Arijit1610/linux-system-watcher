#!/bin/bash

# ================================
# Configuration
# ================================
source /opt/watcher/config.cfg

logfile="$LOG/alertlogger_cpu.log"
alert_sent=0        # 0 = no active alert, 1 = alert already sent
occurrence=0        # Counter to avoid false alerts (debounce)

# ================================
# Infinite monitoring loop
# ================================

while true
do
    # Get CPU idle percentage using mpstat
    cpu_idle=$(mpstat 1 1 | awk '/Average/ {print $NF}')

    # Calculate CPU usage (100 - idle)
    cpu_usage=$(echo "100 - $cpu_idle" | bc | cut -d'.' -f1)

    # ================================
    # Debounce Logic
    # ================================
    # Increase occurrence only if:
    # 1. CPU is above threshold AND alert not sent yet
    # 2. CPU is below threshold AND alert already sent (for recovery)
    # Otherwise reset counter

    if [[ $cpu_usage -gt $threshold && $alert_sent -eq 0 ]]
    then
	echo "CPU ALERT: $(date) ---> usage: $cpu_usage" >> "$logfile"
        ((occurrence++))
    elif [[ $cpu_usage -lt $threshold && $alert_sent -eq 1 ]]
    then
	echo "CPU ALERT: $(date) ---> usage: $cpu_usage" >> "$logfile"
        ((occurrence++))
    else
	echo "CPU ALERT: $(date) ---> usage: $cpu_usage" >> "$logfile"
        occurrence=0   # reset if condition breaks
    fi

    # ================================
    # High CPU Alert Trigger
    # ================================
    if [[ $cpu_usage -gt $threshold && $alert_sent -eq 0 && $occurrence -ge $max_occurrence ]]
    then
        alert_sent=1
        occurrence=0
	echo "CPU ALERT SENT: $(date) ---> usage: $cpu_usage" >> "$logfile" 
	top_process=$(ps -eo pid,ppid,cmd,%cpu,%mem --sort=-%cpu | head -n 11)
	printf "ALERT: CPU Usage Alert\nServer: %s\nUsage: %s%%\nTime: %s\n \nTop Process: \n%s\n " "$(hostname)" "$cpu_usage" "$(date)" "$top_process" | mail -s "$(hostname):High CPU sage Alert" "$EMAIL"

        # Send HTML email alert
	
    fi

    # ================================
    # Recovery Alert (CPU back to normal)
    # ================================
    if [[ $cpu_usage -lt $threshold && $alert_sent -eq 1 && $occurrence -ge $max_occurrence ]]
    then
        alert_sent=0
        occurrence=0
	echo "CPU Alert clear sent: $(date) ---> usage: $cpu_usage" >> "$logfile" 
	printf "ALERT: CPU usage under threshold.\nServer: %s\nUsage: %s%%\nTime: %s\n" "$(hostname)" "$cpu_usage" "$(date)" | mail -s "$(hostname): CPU Alert clear" "$EMAIL"

    fi

    # ================================
    # Sleep before next check
    # ================================
    sleep 10
done

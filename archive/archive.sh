#!/bin/bash
source /opt/watcher/config.cfg
logfile="$LOG/archive.log"

mkdir -p $LOG

if [[ $UID -ne 0 ]]; then
	echo "Please run as root"
	exit 1
fi

shopt -s nullglob

archive_dir() {
	dir="$1"
	prefix="$2"
	time=$(date "+%d-%m-%y_%H-00-00")
	recentfile="${prefix}_output_${time}.dat"
	cd "$path/$dir" || return

	for filename in ${prefix}_output_*.dat
	do
	        #skip recent file
		if [[ "$filename" == "$recentfile" ]]
		then
			continue
		fi

        	# skip already archived
        	[[ -f "$filename.tar.gz" ]] && continue
		echo "Archiving $filename at $(date)" >> "$logfile"
        	tar -czf "$filename.tar.gz" "$filename" && rm -f "$filename"
	done
}

while true
do
	echo "----archiving files---" >> "$logfile"
	archive_dir "wttop" "top"
	archive_dir "wtdf" "df"
	archive_dir "wtfree" "free"
	archive_dir "wtiostat" "iostat"
	archive_dir "wtvmstat" "vmstat"
	echo "-----archiving completed-----" >> "$logfile"
	echo "----deleting old files----" >> "$logfile"
	find $path/*/ -name "*.tar.gz" -type f -mmin +1440 -print -delete >> "$logfile"
	echo "----deletion complete going for sleep 30 mins------" >> "$logfile" 
	sleep 1800   # run every 30 minutes
	
done

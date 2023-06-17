#!/bin/bash
#
# Check whether the backup pool has recent snapshot. Alert othewise.
#
# Based on https://github.com/OliverHi/zfs-homeserver/blob/main/ansible/templates/backupCheck.sh

set -euo pipefail

source /usr/local/lib/zfs-common.sh

LOGFILE="/var/log/zfs-admin/zfs-check-backup.log"

hasRecentBackups=false
for backup_pool in ${BACKUP_POOLS[@]}
do
    if [ "$(zpool_health $backup_pool)" == "healthy" ]
    then
	echo "$(date) - Found online pool $backup_pool" >> $LOGFILE
	# find and compare latest snapshot to today
	lastest_snapshot=$($ZFS list \
                                -t snapshot \
                                -o name \
                                -s creation \
                                -r $backup_pool \
                                  | tail -1 \
                                  | egrep -o '[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}-[[:digit:]]{4}')
	day_start=$(date +"%Y-%m-%d"-0000)
	echo "$(date) - Lastest date from the pool $backup_pool are from $lastest_snapshot and today started at $day_start" >> $LOGFILE

	if [[ "$lastest_snapshot" > "$day_start" ]] ;
	then
	    echo "$(date) - Backups for $backup_pool are up to date" >> $LOGFILE
	    hasRecentBackups=true
	else
	    echo "$(date) - Backups for $backup_pool are not up to date. Last one is from $lastest_snapshot" >> $LOGFILE
	fi
    fi
done

if [ "$hasRecentBackups" = true ]; then
    echo "$(date) - Found recent backups. Run finished" >> $LOGFILE
else
    echo "$(date) - Alarm - no recent backups found!!" >> $LOGFILE
    curl -s \
         -F "token=$PUSHOVER_TOKEN" \
         -F "user=$PUSHOVER_USER" \
         -F "title=No recent backups" \
         -F "message=Unable to find recent backups on the server. Last one is from $lastest_snapshot" \
         https://api.pushover.net/1/messages.json
fi

#!/bin/bash
#
# Script to backup ZFS pool to external drives (with ZFS filesystem)
#
# Based on https://github.com/OliverHi/zfs-homeserver/blob/main/ansible/templates/backup.sh

set -euo pipefail

source /usr/local/lib/zfs-common.sh

LOGFILE="/var/log/zfs-admin/zfs-backup.log"
SYNCOID="/usr/sbin/syncoid"
ZFS_PRUNE="/usr/local/bin/zfs-prune-snapshots"
ZPOOL="/sbin/zpool"


for backup_pool in ${BACKUP_POOLS[@]}
do
    is_online=$(${ZPOOL} status $backup_pool | grep -i 'state: ONLINE' | wc -l)

    if [ $is_online -ge 1 ]
    then
        echo "$(date) - $backup_pool is online. Starting backup..." >> $LOGFILE

        # sync snapshots to backup pool
        for backup_fs in ${BACKUP_FS[@]}
        do
            echo "$(date) - Starting backup of $MAIN_POOL/$backup_fs to $backup_pool " >> $LOGFILE
            $SYNCOID $MAIN_POOL/$backup_fs $backup_pool/backups/$backup_fs --no-sync-snap >> $LOGFILE 2>&1
            echo "$(date) - Backup of $MAIN_POOL/$backup_fs to $backup_pool is done" >> $LOGFILE
        done

        # cleanup
        echo "$(date) - Starting cleanup of backup pool $backup_pool"
        $ZFS_PRUNE -p 'zfs-auto-snap_frequent' 1h $backup_pool  >> $LOGFILE 2>&1
        $ZFS_PRUNE -p 'zfs-auto-snap_hourly' 2d $backup_pool  >> $LOGFILE 2>&1
        $ZFS_PRUNE -p 'zfs-auto-snap_daily' 2M $backup_pool  >> $LOGFILE 2>&1
        $ZFS_PRUNE -p 'zfs-auto-snap_weekly' 3M $backup_pool  >> $LOGFILE 2>&1
        $ZFS_PRUNE -p 'zfs-auto-monthly' 16w $backup_pool  >> $LOGFILE 2>&1
        # yearly kept forever
    else
        echo "$(date) - $backup_pool is not online. Trying to import it" >> $LOGFILE
        ${ZPOOL} import $backup_pool
    fi
done
echo "$(date) - script run done" >> $LOGFILE

#!/bin/bash
#
# Check if the status of zpool is healthy and sent the notification otherwise.
#
# Based on: https://github.com/OliverHi/zfs-homeserver/blob/main/ansible/templates/zpoolStatusCheck.sh

set -euo pipefail

source /usr/local/lib/zfs-common.sh || exit 1

LOGFILE="/var/log/zfs-admin/zfs-status.log"

if [ "$(zpool_health ${MAIN_POOL})" != "healthy" ]; then
    echo "$(date) - Alarm - zpool ${MAIN_POOL} is not healthy" >> $LOGFILE
    curl -s \
         -F "token=$PUSHOVER_TOKEN" \
         -F "user=$PUSHOVER_USER" \
         -F "title=zpool status unhealthy" \
         -F "message=The status of pool ${MAIN_POOL} does not seem to healthy" \
         https://api.pushover.net/1/messages.json
else
    echo "$(date) - zpool ${MAIN_POOL} status is healthy" >> $LOGFILE
fi

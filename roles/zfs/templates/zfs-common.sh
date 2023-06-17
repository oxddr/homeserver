# ZFS
MAIN_POOL="{{ zfs.pool_name }}"
BACKUP_POOLS=({{ zfs.backup.pools | map("to_json") | join(" ") }})
BACKUP_FS=({{ zfs.backup.filesystems | map("to_json") | join(" ") }})

# Pushover
PUSHOVER_TOKEN="{{ vault_pushover.token }}"
PUSHOVER_USER="{{ vault_pushover.user }}"

SYNCOID="/usr/sbin/syncoid"
ZFS="/sbin/zfs"
ZFS_PRUNE="/usr/local/bin/zfs-prune-snapshots"
ZPOOL="/sbin/zpool"


zpool_health() {
    pool=$1
    status=$($ZPOOL status $pool -x || true)
    if [ "$status" != "pool '$pool' is healthy" ]; then
        echo "unhealthy"
    else
        echo "healthy"
    fi
}

# ZFS
MAIN_POOL="{{ zfs.pool_name }}"
BACKUP_POOLS=({{ zfs.backup.pools | map("to_json") | join(" ") }})
BACKUP_FS=({{ zfs.backup.filesystems | map("to_json") | join(" ") }})

# Pushover
PUSHOVER_TOKEN="{{ vault_pushover.token }}"
PUSHOVER_USER="{{ vault_pushover.user }}"

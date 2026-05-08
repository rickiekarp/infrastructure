#!/bin/bash

set -e

echo "Raspberry Pi Restore Script"

device="/dev/sdb"
bootpartition="/dev/sdb1"
rootpartition="/dev/sdb2"

# Exit if backup file was not given
if [[ -z "$1" ]]; then
    echo "Argument missing!"
    echo "Usage: $0 path/to/backup.img"
    exit 1
fi

# Backup file location
backupfile="$1"

# Verify backup file exists
if [[ ! -f "$backupfile" ]]; then
    echo "Backup file not found: $backupfile"
    exit 1
fi

echo "Unmounting boot partition..."
sudo umount "$bootpartition" 2>/dev/null || true

echo "Unmounting root partition..."
sudo umount "$rootpartition" 2>/dev/null || true

echo "Restoring backup to $device ..."
echo "THIS WILL OVERWRITE ALL DATA ON $device"
read -rp "Continue? (y/N): " confirm

if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 1
fi

start_time=$SECONDS

sudo dd if="$backupfile" of="$device" bs=4M status=progress conv=fsync

sync

elapsed=$((SECONDS - start_time))

printf "Restore completed successfully.\n"
printf "Time elapsed: %02d:%02d:%02d\n" \
    $((elapsed / 3600)) \
    $(((elapsed % 3600) / 60)) \
    $((elapsed % 60))

echo "Verifying partition table..."
sudo fdisk -l "$device"

echo "Done."
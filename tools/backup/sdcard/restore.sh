#!/bin/bash
echo "Raspberry Pi Install Script v1.1"

device="/dev/sdb"
bootpartition="/dev/sdb1"
rootpartition="/dev/sdb2"

# exit if backup file was not given
if [[ -z $1 ]]
then
	echo "Argument missing!"
    echo "Please provide a backup file like: $0 path/to/backup.img"
	exit 1
fi

# backup file location
backupfile="$1"

echo "Unmounting boot partition..."
sudo umount $bootpartition
echo "Unmounting root partition..."
sudo umount $rootpartition

echo "Formatting sd card..."
sudo mkdosfs -I -F32 $device

echo "Restoring backup! Please wait..."
sudo dd if=$backupfile of=$device


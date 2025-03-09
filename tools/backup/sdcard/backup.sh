#!/bin/bash
echo "Raspberry Pi Backup Script v1.5"

backupdate=$(date +%Y%m%d)
outputfile="backup.img"
device="/dev/sdb"
bootpartition=$device"1"
rootpartition=$device"2"
echo "Backing up partitions: $bootpartition, $rootpartition"

echo "Unmounting boot partition..."
sudo umount $bootpartition
echo "Unmounting root partition..."
sudo umount $rootpartition

#backup
if df -h | grep $device
then
  echo "Device $device was not unmounted correctly"
else
  echo "Backing up! Please wait..."
  sudo dd if=$device of=$outputfile bs=1M status=progress
  date -ud "@$SECONDS" "+Time elapsed: %H:%M:%S"
fi

echo "Backup created! You can remove the sdcard now!"

mkdir -p $backupdate
echo "Compressing backup, please wait!"
tar -cJvf $backupdate/$outputfile.tar.xz $outputfile

echo "Encrypting backup..."
gpg --output $backupdate/$outputfile.tar.xz.gpg \
    --encrypt \
    --recipient $DEFAULT_EMAIL  \
    $backupdate/$outputfile.tar.xz

echo "Removing $outputfile"
rm $outputfile

echo "Removing unencrypted backup $backupdate/$outputfile.tar.xz"
rm $backupdate/$outputfile.tar.xz
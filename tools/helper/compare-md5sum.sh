#!/bin/bash
# Compares the md5sum of local files ($1) with files on a remote file server ($2)
# USAGE:
# bash git/homesrv/tools/scripts/infrastructure/helper/compare-md5sum.sh /home/rickie/cloud/archive/ /mnt/raid2/applications/cloud/data/archive/files/ *.tar.xz

localBasePath="$1"
remoteBasePath="$2"
fileExtension="$3"
sshRemote="pi"

if [ ! -d "$localBasePath" ]; then
  echo "Path $localBasePath does not exist! Exiting..."
  exit 1
fi

echo "Comparing md5sum of local and remote files"

for file in $(find $localBasePath -mindepth 1 -type f -name "$3"); 
do     
	remoteFilePath="${file/$localBasePath/$remoteBasePath}"
	localMd5Sum=$(md5sum $file | awk '{print $1}')
	remoteMd5Sum=$(ssh $sshRemote md5sum $remoteFilePath | awk '{print $1}')
	if [ "$localMd5Sum" == "$remoteMd5Sum" ]; then
		echo "OK: $localMd5Sum - $file"
	else
		echo "ERR: md5 sum does not match, please check the file:"
		echo "Local: $file"
		echo "Remote: $remoteFilePath"
	fi
done

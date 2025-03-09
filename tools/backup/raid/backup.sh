#!/bin/bash
echo "Raid Backup Script v2024.1"

user="$USER"
workdir=`pwd`
echo "User name: $user"
echo "Working directory: $workdir"

driveA="/media/rickie/archive1/"
if [ -d "$driveA" ]; then
  echo "Starting backup to $driveA!"
  rsync -rlvpt --delete \
    --exclude 'applications/gitea' \
    --exclude 'applications/graphite' \
    --exclude 'applications/mysql' \
    --exclude 'applications/nginx' \
    --exclude 'nodes' \
    --exclude 'projects' \
    root@pi:/mnt/raid2/* \
    $driveA 
else
  echo "---------------------------------------------------"
  echo "WARNING! Directory $driveA not found! Backup skipped!"
  echo "---------------------------------------------------"
fi

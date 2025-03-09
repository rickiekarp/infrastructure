#!/bin/bash
# USAGE:
# bash git/homesrv/tools/scripts/helper/check-for-zero-filesize.sh /home/$USER/foo *.tar.xz

echo "Checking for files with filesize = 0"

path="$1"
extension="$2"

if [ ! -d "$path" ]; then
  echo "Path $path does not exist! Exiting..."
  exit 1
fi

if [ "$extension" = "" ]; then
  extension=*
fi

find "$path" -type f -name "$extension" -print0 | while read -d '' file
do
  if [ $(printf "%q" "$file" | xargs ls -l | awk '{print $5}') -eq "0" ]; then
	echo "FOUND: $file";
  fi
done
#!/usr/bin/env bash
set -eo pipefail

PROCESS_TYPE="none"

currentDate=$(date +%Y%m%d)
workdir=`pwd`
syncFiles=$(dirname "$0")/etc/syncFiles
compressArchiveDotFiles=$(dirname "$0")/etc/compressArchiveDotFiles
compressArchiveCode=$(dirname "$0")/etc/compressArchiveCode
compressionFormat="tar.xz"

function printUsage() {
    echo "Backup Script (2022.09)"
    echo "Usage: $0 [--sync]"
    echo "       $0 [--compress]"
}

function printConfig() {
    echo "User name:   $USER"
    echo "Date:        $currentDate"
    echo "Working dir: $workdir"
    echo "Script path: $(dirname "$0")"
}

while [[ "$1" != "" ]]; do
    case $1 in
        --sync )            PROCESS_TYPE="sync"
                            ;;
        --compress )        PROCESS_TYPE="compress"
                            ;;
        -h | --help )       printUsage
                            exit 0
                            ;;
        * )                 echo "Invalid parameter!"
                            printUsage
                            exit 1
    esac
    shift
done

# sync files to target backup location
function syncFiles() {

  read -r -p "Please define the target directory for your backup! [/media/rickie/Volume]: " target
  target=$target/$currentDate

  # start sync
  read -r -p "Starting sync to $target? [y/n]" response
  case $response in 
    [yY][eE][sS]|[yY]) 
        ;;
    *)
        echo "Exiting..."
        exit 0
        ;;
  esac

  if [ ! -d "$target" ]; then
    echo "Directory $target not found! Creating..."
    mkdir -p $target
    echo "Created: $target!"
  fi

  # check if syncFiles file exists
  if [ ! -f "$syncFiles" ]; then
    echo "Directory $syncFiles not found! Exiting..."
    exit 1
  fi

  echo "Starting sync"

  while IFS= read -r line
  do
    rsync -rlvpt --delete $line $target
  done < "$syncFiles"
}

# compress files for archive
function compressArchive() {

    read -r -p "Please define the directory of your dump! [/home/rickie/$currentDate]: " backupSource    
    if [ ! -d "$backupSource" ]; then
      echo "Directory $backupSource not found!"
      exit 1
    fi
    
    oldDir=$(pwd)
    
    backupTarget=$backupSource/../backup_final
    mkdir -p $backupTarget

    #
    # DOT FILES
    #
    if [ -f "$compressArchiveDotFiles" ]; then
        echo "Archiving .files"
        oldDir=$(pwd)
        while IFS= read -r line
        do
            cd $backupSource
            tar -zcvf $backupTarget/files.$compressionFormat $line
            cd $oldDir
        done < "$compressArchiveDotFiles"
    else
    	echo "File not found $compressArchiveDotFiles"
    fi

    #
    # CODE REPOS
    #
    vcsTypes=( git svn )
    
    if [ -f "$compressArchiveCode" ]; then
        echo "Archiving code repositories"
        while IFS= read -r line
        do
            cd $backupSource
            if [ ! -d "$line" ]; then
            	echo "Directory $line not found"
            	cd $oldDir
                continue
            fi

            # go into base code repository folder
            cd $line
            
            mkdir -p $backupTarget/$line
            echo "Compressing $line"

	    for vcsType in "${vcsTypes[@]}"
	    do
	        for files in $(find * -type d -name "*.$vcsType"); do
		        dir=$(dirname $files)
		        echo $dir
		        if [[ "$dir" == *"/"* ]]; then
		            mkdir -p $backupTarget/$line/$(dirname $dir)
		            tar -zcvf $backupTarget/$line/$dir.$compressionFormat $(dirname $files); 
		        else
		            tar -zcvf $backupTarget/$line/$(dirname $files).$compressionFormat $(dirname $files); 
		        fi
		    done
	    done

            # go back to previously saved directory
            cd $oldDir

        done < "$compressArchiveCode"
    else
    	echo "File not found $compressArchiveCode"
    fi
}

case $PROCESS_TYPE in
    "none" )                echo "No action defined! Please add the parameter --sync, --compress"
                            printUsage
                            exit 1
                            ;;
    "sync" )                printConfig; syncFiles;
                            ;;
    "compress" )            printConfig; compressArchive
                            ;;
    * )                     echo "Invalid action! ($PROCESS_TYPE)"
                            exit 1
esac

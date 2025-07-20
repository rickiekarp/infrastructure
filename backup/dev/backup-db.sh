#!/bin/bash

dataDir="./data"

if [ -d $dataDir ]; then
    echo "Directory $dataDir found, removing..."
    rm -rf $dataDir
fi

mkdir data

# --------------------------
# create database backups
# --------------------------
echo "Dumping databases"
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases login > $dataDir/login.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases nexus > $dataDir/nexus.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases storage > $dataDir/storage.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases mysql > $dataDir/mysql.sql

# --------------------------
# compress database backups
# --------------------------
echo "Compressing dump"
tar cJPf $dataDir/dumps.tar.xz $dataDir/*.sql
rm $dataDir/*.sql

# --------------------------
# encrypt database backups
# --------------------------
echo "Encrypting for recipient: $DEFAULT_EMAIL"
gpg --output $dataDir/dumps.tar.xz.gpg --encrypt --recipient $DEFAULT_EMAIL $dataDir/dumps.tar.xz

# --------------------------
# sync database backups
# --------------------------
echo "Syncing backup"
rsync -rlvpt $dataDir/dumps.tar.xz.gpg pi:/mnt/raid2/archive/database/development/

# --------------------------
# remove database backups
# --------------------------
rm -rf data

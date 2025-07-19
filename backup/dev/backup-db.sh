#!/bin/bash

mkdir data

# --------------------------
# create database backups
# --------------------------
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases login > ./data/login.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases nexus > ./data/nexus.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases storage > ./data/storage.sql
docker exec -it database mariadb-dump --defaults-file="/home/defaults.cnf" --routines --databases mysql > ./data/mysql.sql

# --------------------------
# compress database backups
# --------------------------
tar -zcvf backup.tar.xz data/*; 

# --------------------------
# sync database backups
# --------------------------
rsync -rlvpt backup.tar.xz pi:/mnt/raid2/development/backups/database/

# --------------------------
# remove database backups
# --------------------------
rm backup.tar.xz
rm -rf data

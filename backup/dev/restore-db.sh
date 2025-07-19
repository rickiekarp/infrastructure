#!/bin/bash

mkdir data

# --------------------------
# sync database backups
# --------------------------
rsync -rlvpt pi:/mnt/raid2/development/backups/database/backup.tar.xz data/

# --------------------------
# extract dump
# --------------------------
tar -xvf data/backup.tar.xz

# --------------------------
# create database backups
# --------------------------
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/login.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/nexus.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/storage.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/mysql.sql

# --------------------------
# remove data directory
# --------------------------
rm -rf data

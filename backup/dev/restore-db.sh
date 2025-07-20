#!/bin/bash

mkdir data

# --------------------------
# sync database backups
# --------------------------
rsync -rlvpt pi:/mnt/raid2/archive/database/development/dumps.tar.xz.gpg data/

# --------------------------
# decrypt database backups
# --------------------------
gpg --output ./data/dumps.tar.xz --decrypt ./data/dumps.tar.xz.gpg

# --------------------------
# extract dump
# --------------------------
tar -xvf data/dumps.tar.xz

# --------------------------
# restore database backups
# --------------------------
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/login.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/nexus.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/storage.sql
docker exec -i database mariadb --defaults-file="/home/defaults.cnf" < ./data/mysql.sql

# --------------------------
# remove data directory
# --------------------------
rm -rf data

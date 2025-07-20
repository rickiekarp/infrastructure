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
tar cJPf ./data/dumps.tar.xz ./data/*.sql
rm ./data/*.sql

# --------------------------
# encrypt database backups
# --------------------------
gpg --output ./data/dumps.tar.xz.gpg --encrypt --recipient rickie.karp@yandex.com ./data/dumps.tar.xz

# --------------------------
# sync database backups
# --------------------------
rsync -rlvpt ./data/dumps.tar.xz.gpg pi:/mnt/raid2/archive/database/development/

# --------------------------
# remove database backups
# --------------------------
rm -rf data

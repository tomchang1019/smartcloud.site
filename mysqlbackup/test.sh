#!/bin/bash

## enviroment variable

path=/project/backup-db
DATE=$(date +"%Y%m%d%H")
USER="root"
PASS="Aa-123456789"
DATABASES=$(mysql -u $USER -p$PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

## backup dir check
[ ! -d $path ] && mkdir -p $path

##


for db in $DATABASES; do
  FILE="${DEST}/mysql-$DATE-$db.sql.gz"
  FILEDATE=

  # Be sure to make one backup per day
  [ -f $FILE ] && FILEDATE=$(date -r $FILE +"%F")
  [ "$FILEDATE" == "$DATE" ] && continue

  [ -f $FILE ] && mv "$FILE" "${FILE}.old"
  mysqldump --single-transaction --routines --quick -h $HOSTNAME -u $USER -p$PASS -B $db | gzip > "$FILE"
  rm -f "${FILE}.old"
done

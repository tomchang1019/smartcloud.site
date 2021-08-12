#!/bin/bash

# Destiny folder where backups are stored
DEST=/project/backup-db
TODAY=$(date +"%Y%m%d%H")
USER="root"
PASS="Aa-123456789"
DATABASES=$(mysql -u $USER -p$PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

# backup destination check
[ ! -d $DEST ] && mkdir -p $DEST

# backup
for db in $DATABASES; do
  FILE="${DEST}/mysql-$TODAY-$db.sql"
  mysqldump --single-transaction -u $USER  -p$PASS $db > "$FILE" ; tar cfzP $FILE.tar.gz $FILE
  /usr/bin/rm $FILE
done

# delete files older than 10 days
find $DEST -type f -mtime +10 -delete

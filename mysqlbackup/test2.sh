
#!/bin/bash

# Destiny folder where backups are stored
DEST=/project/backup-db
CURRDATE=$(date +"%Y%m%d%H")
USER="root"
PASS="Aa-123456789"

DATABASES=$(mysql -u $USER -p$PASS -e "SHOW DATABASES;" | tr -d "| " | grep -v Database)

[ ! -d $DEST ] && mkdir -p $DEST

for db in $DATABASES; do
  FILE="${DEST}/mysql-$CURRDATE-$db.sql.gz"
  FILEDATE=

  # Be sure to make one backup per day
  [ -f $FILE ] && FILEDATE=$(date -r $FILE +"%F")
  [ "$FILEDATE" == "$CURRDATE" ] && continue

  [ -f $FILE ] && mv "$FILE" "${FILE}.old"
  mysqldump --single-transaction --routines --quick -h $HOSTNAME -u $USER -p$PASS -B $db | gzip > "$FILE"
  rm -f "${FILE}.old"
done


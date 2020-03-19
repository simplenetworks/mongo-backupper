#!/bin/bash

set -e

echo "Backup Job started"

DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p /backups

echo "Starting mongo dump"
MONGO_FILE="/backups/$DATE-mongo-backup.tar.gz"
mkdir -p dump
mongodump -h $MONGO_HOST -p $MONGO_PORT
tar -zcf $MONGO_FILE dump/
rm -rf dump/
echo "Mongo dump completed"

echo "Starting documents backup"
DOCUMENTS_FILE="/backups/$DATE-documents-backup.tar.gz"
tar -zcf $DOCUMENTS_FILE /documents
echo "Documents backup completed"

echo "Start sending backups to FTP server"
ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $MONGO_FILE
rm -f $MONGO_FILE
ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $DOCUMENTS_FILE
rm -f $DOCUMENTS_FILE
echo "Backups sent to FTP server"
rm -rf backups/

if [[ "$BACKUP_DAYS" ]]; then
  echo "Start cleaning backups older than $BACKUP_DAYS days"
  CLEAN_OLD_SCRIPT_PATH="/clean-old-backups.sh"
  "$CLEAN_OLD_SCRIPT_PATH"
fi

echo "Backup Job finished"
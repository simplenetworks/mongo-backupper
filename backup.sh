#!/bin/bash

set -e

echo "Backup Job started"

DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p /backups

echo "Starting mongo dump"
MONGO_FILE="/backups/mongo-backup.tar.gz"
mkdir -p dump
mongodump -h $MONGO_HOST -p $MONGO_PORT
tar -zcf $MONGO_FILE dump/
rm -rf dump/
echo "Mongo dump completed"

# if [[ "$DOCUMENTS_BACKUP" ]]; then
#   : "${DOCUMENTS_FOLDER:=/documents}"
#   echo "Starting documents backup from $DOCUMENTS_FOLDER"
#   DOCUMENTS_FILE="/backups/$DATE-documents-backup.tar.gz"
#   tar -zcf $DOCUMENTS_FILE $DOCUMENTS_FOLDER
#   echo "Documents backup completed"
# fi

echo "Start sync mongo backups with AWS"
# ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $MONGO_FILE
aws s3 sync ./backups/ s3://backup.fisioweb.net/mongo
echo "End sync mongo backups"
#rm -f $MONGO_FILE
if [[ "$DOCUMENTS_BACKUP" ]]; then
  : "${DOCUMENTS_FOLDER:=/documents}"
  echo "Start synching documents from $DOCUMENTS_FOLDER to AWS"
  aws s3 sync /documents/ s3://backup.fisioweb.net/documents
  echo "Sync documents completed"
  # ncftpput -u $FTP_USER -p $FTP_PASSWORD -o useCLNT=0,useMLST=0,useSIZE=0,allowProxyForPORT=1 $FTP_HOST $FTP_BACKUP_FOLDER $DOCUMENTS_FILE
  # rm -f $DOCUMENTS_FILE
fi
# echo "Backups sent to FTP server"
# rm -rf backups/

# if [[ "$BACKUP_DAYS" ]]; then
#   echo "Start cleaning backups older than $BACKUP_DAYS days"
#   CLEAN_OLD_SCRIPT_PATH="/clean-old-backups.sh"
#   "$CLEAN_OLD_SCRIPT_PATH"
# fi

echo "Backup Job finished"

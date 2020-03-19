#!/bin/bash

set -e

CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
export MONGO_HOST=${MONGO_HOST:-mongo}
export MONGO_PORT=${MONGO_PORT:-27017}
export FTP_HOST=${FTP_HOST:-ftp.simplevault.it}
export FTP_USER=${FTP_USER:-2674000@aruba.it}
export FTP_PASSWORD=${FTP_PASSWORD:-cdezxww2}
export FTP_BACKUP_FOLDER=${FTP_BACKUP_FOLDER:-www.simplevault.it/fisioweb}

if [[ "$1" == 'no-cron' ]]; then
    exec /backup.sh
else
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="MONGO_HOST='$MONGO_HOST'"
    CRON_ENV="$CRON_ENV\nMONGO_PORT='$MONGO_PORT'"
    CRON_ENV="$CRON_ENV\nFTP_HOST='$FTP_HOST'"
    CRON_ENV="$CRON_ENV\nFTP_USER='$FTP_USER'"
    CRON_ENV="$CRON_ENV\nFTP_PASSWORD='$FTP_PASSWORD'"
    CRON_ENV="$CRON_ENV\nFTP_BACKUP_FOLDER='$FTP_BACKUP_FOLDER'"
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1" | crontab -
    crontab -l
    cron
    tail -f "$LOGFIFO"
fi
#!/bin/bash

set -e

CRON_SCHEDULE=${CRON_SCHEDULE}

LOGFIFO='/var/log/cron.fifo'
if [[ ! -e "$LOGFIFO" ]]; then
    mkfifo "$LOGFIFO"
fi
declare -p | grep -Ev 'BASHOPTS|BASH_VERSINFO|EUID|PPID|SHELLOPTS|UID' >/container.env
echo -e "SHELL=/bin/bash\nBASH_ENV=/container.env" | crontab -
LINE="$CRON_SCHEDULE /backup.sh > $LOGFIFO 2>&1"
(
    crontab -l
    echo -e "$LINE"
) | crontab -
crontab -l
cron
tail -f "$LOGFIFO"

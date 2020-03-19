#!/bin/bash
# https://stackoverflow.com/questions/11203988/linux-shell-script-for-delete-old-files-from-ftp
# get a list of files and dates from ftp and remove files older than ndays
ftpsite=$FTP_HOST
ftpuser=$FTP_USER
ftppass=$FTP_PASSWORD
putdir=$FTP_BACKUP_FOLDER

ndays=$BACKUP_DAYS

# work out our cutoff date
MM=`date --date="$ndays days ago" +%b`
DD=`date --date="$ndays days ago" +%d`

echo removing files older than $MM $DD
MONTH_NUMBER=$(date -d "$MM $DD" '+%m')
MONTH_NUMBER=$(tr -dc '0-9' <<< $MONTH_NUMBER)
DD=$(tr -dc '0-9' <<< $DD)

MONTH_NUMBER=${MONTH_NUMBER#0}
DD=${DD#0}

listing=`lftp -u $ftpuser,$ftppass $ftpsite << EOF
cd $putdir
ls
bye
EOF
`

lista=( $listing )

# loop over our files
for ((FNO=0; FNO<${#lista[@]}; FNO+=9));do
  # month (element 5), day (element 6) and filename (element 8)
  #echo Date ${lista[`expr $FNO+5`]} ${lista[`expr $FNO+6`]} File: ${lista[`expr $FNO+8`]}
   # echo FNO $FNO
  # check the date stamp
   FILE_MONTH=$(date -d "${lista[`expr $FNO+5`]} ${lista[`expr $FNO+6`]}" '+%m')
FILE_MONTH=$(tr -dc '0-9' <<< $FILE_MONTH)
FILE_MONTH=${FILE_MONTH#0}
    if ((FILE_MONTH < MONTH_NUMBER));
    then 
 echo "Removing ${lista[`expr $FNO+8`]}"
      lftp -u $ftpuser,$ftppass $ftpsite <<EOMYF
      cd $putdir
      rm ${lista[`expr $FNO+8`]}
      bye
EOMYF
    fi

   if [ ${lista[`expr $FNO+5`]}=$MM ];
   then
     if [[ ${lista[`expr $FNO+6`]#0} -lt $DD ]];
     then
      # Remove this file
      echo "Removing ${lista[`expr $FNO+8`]}"
      lftp -u $ftpuser,$ftppass $ftpsite <<EOMYF
      cd $putdir
      rm ${lista[`expr $FNO+8`]}
      bye
EOMYF

     fi
   fi
done
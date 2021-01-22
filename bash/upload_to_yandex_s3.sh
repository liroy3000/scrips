#!/bin/sh
BACKUP_LOCAL_PATH="/path/to/local/backup"
BUCKET_NAME="backet_name"
BACKUP_NAME="backup_site_name"
DATE=$(date +%Y%m%d)

/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 cp $BACKUP_LOCAL_PATH/*$DATE.tar.gz s3://$BUCKET_NAME/$BACKUP_NAME/
/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 cp $BACKUP_LOCAL_PATH/*$DATE.sql.gz s3://$BUCKET_NAME/$BACKUP_NAME/
/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 ls s3://$BUCKET_NAME/$BACKUP_NAME/ | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`
    echo $createDate
    olderThan=`date --date "30 days ago" +%s`
    echo $olderThan
    if [ $createDate -lt $olderThan ]
      then
      fileName=`echo $line|awk {'print $4'}`
      if [ $fileName != "" ]
        then
        /usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 rm s3://$BUCKET_NAME/$BACKUP_NAME/$fileName
        fi
      fi
  done;

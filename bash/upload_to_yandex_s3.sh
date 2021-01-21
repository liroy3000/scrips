#/bin/sh
# $2 - path to backup
bucket_name="backet_name"
backup_name="backup_site_name"

/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 cp $2/*$dat.tar.gz s3://$bucket_name/$backup_name/
/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 cp $2/*$dat.sql.gz s3://$bucket_name/$backup_name/
/usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 ls s3://$bucket_name/$backup_name/ | while read -r line;
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
        /usr/local/bin/aws --endpoint-url=https://storage.yandexcloud.net s3 rm s3://$bucket_name/$backup_name/$fileName
        fi
      fi
  done;
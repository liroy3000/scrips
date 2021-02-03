#!/bin/bash
# Скрипт копирует резеврные копии в удаленное nfs хранилище.
# Файлы резервных копий имеют дату в названии файла, это важно для нормальной работы скрипта.
# Скрипт фасует копии на ежедневные, еженедельные и ежемесячные.

MOUNT_POINT='/mnt/nfs'
MOUNT_SOURCE='<ip_address>:/mnt/path'
CUR_DATE=$(date +%Y%m%d)
BACKUP_DIR='/home/bitrix/backups'

mount -t nfs $MOUNT_SOURCE $MOUNT_POINT

# Check local backup
BACKUP_DATE=`tail -n1 /usr/local/zabbix/tmp/backup_info_backups | awk '{print $2}'`
if [[ ! $CUR_DATE -eq $BACKUP_DATE ]]; then 
	echo 'Local backup not finished!'
	exit 1
fi

# Copy dauly backup
cp $BACKUP_DIR/*"$CUR_DATE"* $MOUNT_POINT/daily/
find $MOUNT_POINT/daily -type f -atime +7 -delete
# Copy weekly backup
if [[ `date +"%u"` -eq 1 ]]; then
  cp $BACKUP_DIR/*"$CUR_DATE"* $MOUNT_POINT/weekly/
  find $MOUNT_POINT/weekly -type f -atime +28 -delete
fi
# Copy monthly backup
if [[ `date +"%d"` -eq 01 ]]; then
  cp $BACKUP_DIR/*"$CUR_DATE"* $MOUNT_POINT/monthly/
  find $MOUNT_POINT/monthly -type f -atime +365 -delete
fi

# Copy etc backup
cp /root/backups/backups_dir_etc/*"$CUR_DATE"* $MOUNT_POINT/etc/
find $MOUNT_POINT/daily -type f -atime +30 -delete

umount $MOUNT_POINT 

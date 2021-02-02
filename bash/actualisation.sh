#!/bin/bash

# This is script for actualisation dev sites. Run: bash ~/bin/actualisation_dev.sh <dev site name>
# $1 - dev site name [dev1.example.org|dev2.example.org]

DB_PROD_USER="mysql_login_prod"
DB_PROD_PSW="mysql_password_prod"
DB_PROD_NAME="mysql_db_name_prod"
DIR_PROD="/path/to/prod"

case $1 in
	"dev1.example.org")
		DB_DEV_USER="mysql_login_dev1"
		DB_DEV_PSW="mysql_password_dev1"
		DB_DEV_NAME="mysql_db_name_dev1"
		DIR_DEV="/path/to/dev1"
		;;
	"dev2.example.org")
		DB_DEV_USER="mysql_login_dev2"
		DB_DEV_PSW="mysql_password_dev2"
		DB_DEV_NAME="mysql_db_name_dev2"
		DIR_DEV="/path/to/dev2"
		;;
	# More dev sites
esac
# Actualisation DB
mysqldump -u"$DB_PROD_USER" -p"$DB_PROD_PSW" --lock-tables=false "$DB_PROD_NAME" | mysql -u"$DB_DEV_USER" -p"$DB_DEV_PSW" "$DB_DEV_NAME"
# Actualication files
rsync -av --delete "$DIR_PROD"/ "$DIR_DEV"/ --exclude='bitrix/backup/' --exclude='bitrix/cache/' --exclude='bitrix/managed_cache/' --exclude='log_ecomerce.txt' --exclude='maillog.txt' --exclude='bitrix/php_interface/dbconn.php' --exclude='bitrix/.settings.php' --exclude='bitrix/ammina.cache/' --exclude='.htaccess'

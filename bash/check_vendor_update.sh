#!/bin/bash

# Author: Konstantin Kulkov <k.kulkov@initlab.ru>
# Only project using composer!
# $1 - path to composer.lock
# return value:
# 0 - No packages have known vulnerabilities (Good response)
# 1 - composer.lock file does not exist
# Text - List of available updates (Good responce)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
composer_file=$1
php_path=$2
if [[ $composer_file != *composer.lock ]]; then
  # return error code
  echo 1
  exit
fi

# update local-php-security-checker
security_checker=$DIR/security-checker.phar
wget -qO $security_checker https://github.com/fabpot/local-php-security-checker/releases/download/v1.0.0/local-php-security-checker_1.0.0_linux_amd64
chmod +x $security_checker

update_data=`$security_checker --path=$composer_file`
if [[ `echo $update_data | grep -c 'No packages have known vulnerabilities'` == 1 ]]; then
  # return error code
  echo 0
elif [[ `echo $update_data | grep -c 'Lock file does not exist'` == 1 ]]; then
  # return error code
  echo 1
else
  # return list updates
  echo $update_data
fi

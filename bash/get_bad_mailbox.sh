#/bin/bash

# Скрипт выгружает несуществующие электронные адреса из лога Exim

mkdir -p /tmp/bad_mailbox
touch /tmp/bad_mailbox/bad_mailbox.list
cd /tmp/bad_mailbox
grep ' 550 ' /var/log/exim4/mainlog.1 | awk '{print $5}' >> grep_tmp
grep ' 550 ' /var/log/exim4/mainlog | awk '{print $5}' >> grep_tmp
cat bad_mailbox.list >> grep_tmp
awk '!seen[$0]++' grep_tmp > bad_mailbox.list    # удаление дублей
rm -rf grep_tmp

if [[ `date +"%u"` -eq 7 ]]; then
	mv bad_mailbox.list bad_mailbox.$(date +%Y%m%d).list
fi
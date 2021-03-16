#!/bin/bash

cd /tmp/setup
ls -l /tmp/setup
dpkg -i *.deb
sed -i '~s,/var/lib/zabbix/:/sbin/nologin,/var/lib/zabbix/:/bin/bash,' /etc/passwd
#cat /etc/passwd

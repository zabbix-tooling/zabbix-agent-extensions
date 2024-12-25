#!/bin/bash

cd /tmp/setup
ls -l /tmp/setup
dpkg -i *.deb
sed -i '~s,/var/lib/zabbix/:/sbin/nologin,/var/lib/zabbix/:/bin/bash,' /etc/passwd
echo "Include=/usr/share/zabbix-agent-extensions/include.d/*.conf" >  /etc/zabbix/zabbix_agentd.d/zabbix-agent-extensions.conf

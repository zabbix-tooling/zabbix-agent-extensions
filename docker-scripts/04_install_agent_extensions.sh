#!/bin/bash

set -xe
cd /tmp/setup
ls -l /tmp/setup
dpkg -i "zabbix-agent-extensions_${BUILD_VERSION?The version of the extension}_all.deb"
sed -i '~s,/var/lib/zabbix/:/sbin/nologin,/var/lib/zabbix/:/bin/bash,' /etc/passwd

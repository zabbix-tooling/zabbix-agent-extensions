#!/bin/bash

FAILED_TESTS=""

assertSuccess(){
 local STRATEGY="$1"
 local CMD="$2"
 echo "****************************************************************************"
 echo "** EXECUTE: $CMD";
 eval "$CMD 2>&1"
 local RET="$?"
 echo "**"

 if [ "$RET" != "0" ];then
   echo "** ERROR: execution failed (returncode $RET)"
   FAILED_TESTS="$FAILED_TESTS#assertSuccess => $CMD"
   echo "****************************************************************************"
   if [ "$STRATEGY" = "STOP_ON_ERROR" ];then
      exit 100
   else
      return 100
   fi
 fi
 echo "****************************************************************************"
 return 0
}


echo "*** CLEANUP"
REL="3.2.8-1+xenial"
dpkg -P zabbix-agent-extensions
sudo rm -rf /etc/zabbix_* /var/log/zabbix /var/run/zabbix
wget "http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix/zabbix-agent_${REL}_amd64.deb "
wget "http://repo.zabbix.com/zabbix/3.2/ubuntu/pool/main/z/zabbix/zabbix-get_${REL}_amd64.deb"
ls -l *.deb
sudo dpkg -i zabbix-agent_*.deb zabbix-get_*.deb 

echo "*** TESTS"

assertSuccess STOP_ON_ERROR "sudo dpkg -i zabbix-agent-extensions_*.deb"
assertSuccess STOP_ON_ERROR "zabbix_get -s 127.0.0.1 -k linux.dmesg|grep 'OK: ALL OK'" # Without sudo
assertSuccess STOP_ON_ERROR "zabbix_get -s 127.0.0.1 -k linux.multipath|grep 'OK:" # With sudo
assertSuccess STOP_ON_ERROR 'sudo dpkg -P zabbix-agent-extensions'

echo
echo
echo "*** SUMMARY"
if [ -z "$FAILED_TESTS" ];then
   echo "ALL TESTS PASSED"
   exit 0
else
   echo "THE FOLLOWING TESTS FAILED"
   echo "$FAILED_TESTS"|tr '#' '\n'|sed '~s,^, ,'
   exit 1
fi


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
dpkg -P zabbix-agent-extensions
rm -rf /etc/zabbix_* /var/log/zabbix /var/run/zabbix

echo "*** TESTS"
assertSuccess STOP_ON_ERROR 'sudo dpkg -i zabbix-agent-extensions_*_all.deb'

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


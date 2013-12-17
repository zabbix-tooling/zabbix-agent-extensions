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
rpm -e zabbix-agent-extensions
zypper  --non-interactive install  zabbix-agent
rm -rf /etc/zabbix_*

echo "*** TESTS"

assertSuccess STOP_ON_ERROR 'rpm -hiv noarch/zabbix-agent-extensions-*.noarch.rpm'

for item in `cat /etc/zabbix/zabbix-agentd.d/*|grep UserParameter|sed '~s,UserParameter=,,'|awk -F',' '{print $1}'`; do 
  assertSuccess CONTINUE_ON_ERROR "zabbix_agentd -t $item; zabbix_agentd -t $item 2>/dev/null|grep -v -q ZBX_NOTSUPPORTED"
done

assertSuccess STOP_ON_ERROR 'rpm -e zabbix-agent-extensions'

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


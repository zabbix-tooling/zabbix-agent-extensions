#enabling nginx stats to be read by zabbix_check_nginx-status:
put following configuration on your nginx.conf file:

```
location /basic_status {
stub_status on;
access_log off;
allow 127.0.0.1;
deny all;}
```
and reload the nginx


#Copy the files 
```
https://github.com/hamidsfandiari/zabbix-agent-extensions/blob/patch-2/agent-scripts/tools/zabbix_check_nginx-status
zabbix_check_nginx-status => /usr/bin/;
https://github.com/hamidsfandiari/zabbix-agent-extensions/blob/patch-2/agent-scripts/agent-config/zabbix_nginx-status.conf
zabbix_nginx-status.conf => /etc/zabbix/zabbix_agentd.d/

chmod +x /usr/bin/zabbix_check_nginx-status
chown zabbix:zabbix /usr/bin/zabbix_check_nginx-status /etc/zabbix/zabbix_agentd.d/zabbix_nginx-status.conf
```

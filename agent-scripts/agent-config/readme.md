enabling nginx stats to be read by zabbix_check_nginx-status:
put following configuration on your nginx.conf file:

location /basic_status {
stub_status on;
access_log off;
allow 127.0.0.1;
deny all;}

and reload the nginx



zabbix_check_nginx-status => /usr/bin/;
zabbix_nginx-status.conf  => /etc/zabbix/zabbix_agentd.d/

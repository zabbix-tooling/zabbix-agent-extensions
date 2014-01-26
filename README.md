zabbix-agent-extensions
=======================

A set of zabbix UserParameter scripts and a monitoring template for linux systems.


# Monitoring details

This set of of zabbix UserParameter scripts and the template provides the follwing capabilities:

 * Linux standard monitoring using the standard items provided by the zabbix-agent
   * Monitor all local filesystems using dicovery
   * Monitor all interfaces using dicovery
   * Monitor memory behavior
   * Monitor important servcies: smtp, ssh, ntp time difference to zabbix server
   * Swap usage
   * 5min system load
 * ICMP Ping of the system
 * Monitor the MTA mailqueue
 * Monitor NFS operations/retransmits
 * Apache Monitoring:
   * Check Apache Server-Status (Readers, Writers - alert if to many slots are in use)
   * Loadbalancer check

# How to install the userparameter scripts

Invoke the following procedure on your system for package builds
```
git clone https://github.com/scoopex/zabbix-agent-extensions.git
cd zabbix-agent-extensions
./ci_build.sh
./ci_test.sh
```

Install the rpm archive on every zabbix-agent:
```
rpm -Uvh zabbix-agent-extensions-<version>.noarch.rpm
```

Add the follwing line to your zabbix-agent configuration:
```
Include=/etc/zabbix/zabbix-agent-extensions.d/
```

# How to configure the zabbix server

The template will work on zabbix 2.2 and above.

 * Open Zabbix web frontend
 * Open "Configuration" => "Templates"
 * Press button "Import"
 * Activate Linux template
   * Load "zabbix_templates/Custom - OS - Linux.xml"
   * Open template "Custom - OS - Linux" and modify the default values defined in the macros
   * Assign template "Custom - OS - Linux" to the desired hosts and modify the default values to host specific settings
 * Activate Apache template
   * Load "zabbix_templates/Custom - Service - Apache.xml"
   * Open template "Custom - Service - Apache" and modify the default values defined in the macros
   * Assign template "Custom - Service - Apache" to the desired hosts and modify the default values to host specific settings


# Licence and Authors

Additional authors are very welcome - just submit your patches as pull requests.

  * Marc Schoechlin <ms@256bit.org>
 
This software is licensed by GPLv2 - review file "LICENSE"

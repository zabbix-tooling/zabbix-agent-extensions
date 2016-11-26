zabbix-agent-extensions
=======================

A set of zabbix UserParameter scripts and a monitoring template for linux systems.


# Monitoring details

This package provides the following capabilities:

 * Linux standard monitoring using the standard items provided by the zabbix-agent
   * Monitor all local filesystems using dicovery
   * Monitor all interfaces using dicovery
   * Monitor memory behavior
   * Monitor important servcies: smtp, ssh, ntp time difference to zabbix server
   * Swap usage
   * 5min system load
   * Monitor dmesg for bad behavior of the system
   * Monitor the maximum and minimum of processes
 * ICMP Ping of the system
 * Monitor the MTA mailqueue
 * Monitor NFS operations/retransmits
 * Apache Monitoring:
   (enable /server-status available on localhost, https://httpd.apache.org/docs/2.4/mod/mod_status.html)
   * Check Apache Server-Status (Readers, Writers - alert if to many slots are in use)
   * Loadbalancer check
   * Monitor Mod JK backend status
 * Elasticsearch Node and Cluster Monitoring (needs elasticsearch and es_stats_zabbix Python modules)
 * Redis Monitoring (needs redis Python module)
 * NGINX Monitoring
   (enable /basic_status available on localhost, https://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
 * Generic discovery
   (put json snippets to /var/run/zabbix-generic-discovery/<ITEMNAME>-*.json i.e. with puppet and get a combined discovery value)
 * Monitor Puppet state

# How to test and debug

 * Install the packages on the zabbix agent host
 * Test the agent on the agent machine
 
   ```
   zabbix_agentd  -t linux.dmesg
   zabbix_agentd --print
   ```
 * Test the agent on the server machine
 
   ```
   apt-get install zabbix-get
   zabbix_get -s 127.0.0.1 -k linux.dmesg
   ```

# How to release and/or install the userparameter scripts

 * Release only: Edit this file (README.md) and describe the new feature
 * Release only: Modify/release version information
   * agent-scripts/debian/changelog (use "date -R" for a proper timestamp)
   * zabbix-agent-extensions.spec
 * Invoke the following procedure on your system for package builds on a Ubuntu 14.04 System
   (creates RPM and DEB packages)

   ```
   sudo apt-get install debhelper devscripts rpm
   git clone https://github.com/breuninger-ecom/zabbix-agent-extensions
   cd zabbix-agent-extensions
   ./ci_build.sh
   # Only for testing purposes on RPM based systems
   ./ci_test.sh
   ```
 * Install the rpm ior debian archive on as an addition to your zabbix-agents:
 
   ```
   rpm -Uvh noarch/zabbix-agent-extensions-<version>.noarch.rpm
   dpkg -i zabbix-agent-extensions_<version>_all.deb
   ```
 * Add the following line to your zabbix-agent configuration:
 
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
  * Marc Schoechlin <marc.schoechlin@breuninger.de>
 
This software is licensed by GPLv2 - review file "LICENSE"

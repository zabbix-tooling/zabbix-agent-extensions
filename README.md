zabbix-agent-extensions
=======================

# Overview

A set of zabbix UserParameter scripts and a monitoring template for linux systems.

 * this project ist originated on: https://github.com/scoopex/zabbix-agent-extensions
 * this project is presented at zabbix share: https://share.zabbix.com/operating-systems/zabbix-agent-extensions
 * the ci is located at: https://travis-ci.org/scoopex/zabbix-agent-extensions

# Monitoring details

This package provides the following capabilities:

 * linux standard monitoring using the standard items provided by the zabbix-agent
   * monitor memory behavior
   * monitor important servcies: smtp, ssh, cron
   * swap usage
   * 5min system load
   * monitor dmesg for bad behavior of the system
   * monitor the maximum and minimum of processes
   * automatic discovery
      * filesystems: inode and space measures<BR>
        (the amount of discovered filesystems can be limited by a configuration file on the monitored host)
      * network interfaces: packets and transferrates per second
      * storage devices: operations per second
        (the amount of discovered devices can be limited by a configuration file on the monitored host)
      * network interfaces: packets and transferrates per second
   * number of processes
 * monitor ICMP ping 
 * monitor the MTA mailqueue
 * monitor NFS operations/retransmits
 * apache monitoring:
   (enable /server-status for localhost clients, https://httpd.apache.org/docs/2.4/mod/mod_status.html)
   * Check Apache Server-Status (Readers, Writers - alert if to many slots are in use)
   * Loadbalancer check
   * Monitor Mod JK backend status
 * elasticsearch node and cluster monitoring (needs elasticsearch and es_stats_zabbix Python modules)
 * redis Monitoring (needs redis Python module)
 * NGINX Monitoring
   (enable /basic_status only for localhost clients, https://nginx.org/en/docs/http/ngx_http_stub_status_module.html)
 * generic discovery
   (put json snippets to /var/run/zabbix-generic-discovery/ITEMNAME.json i.e. with puppet and get a combined discovery value)
 * monitor puppet state
   (execution statistics, disabled state, ...)
 * linux software raid state
 * check quality of ntp sync behavior
 * check for required reboot
 * monitor open file descriptors
 * Configurable autodiscovery of block devices
 * Monitor performance havior of discovered block devices
 * Configurable autodisovery of real disk devices
 * Check smart state of disks and gather statistics
 * Discover network devices and monitor performance and error behavior
 * Zabbix agent version 


Almost all measures are integrated in graphs which are displayed on the various host screens.

The project inlcudes various zabbix templates for relase 3.4.

Note: There are also 2.2 and 3.0 templates, but they are outdated because we do not support them anymore. Probably these outdated templates might be a good starting point for your own environment.

A quick is provided by the following files:

 * [custom-os-linux](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-os-linux.html)
 * [custom-os-linux-hardware](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-os-linux-hardware.html)
 * [custom-os-puppet](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-os-puppet.html)
 * [custom-service-apache](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-apache.html)
 * [custom-service-cups](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-cups.html)
 * [custom-service-elasticsearch-cluster](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-elasticsearch-cluster.html)
 * [custom-service-elasticsearch-node](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-elasticsearch-node.html)
 * [custom-service-nginx](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-nginx.html)
 * [custom-service-nginx-logstats](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-nginx-logstats.html)
 * [custom-service-redis](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-redis.html)
 * [custom-service-varnish](http://htmlpreview.github.io/?https://github.com/scoopex/zabbix-agent-extensions/blob/master/zabbix_templates/3.4/documentation/custom-service-varnish.html)


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

   Adpoted from: https://www.digitalocean.com/community/tutorials/how-to-use-fpm-to-easily-create-packages-in-multiple-formats

 * Install FPM
   ```
   sudo apt-get install ruby-dev build-essential debhelper devscripts rpm
   gem install fpm --user
   ```
 * Get the repo 
   ```
   git clone https://github.com/scoopex/zabbix-agent-extensions
   cd zabbix-agent-extensions
   ```
 * Release only: Edit this file (README.md) and describe the new feature
 * Create packages
   ```
   git commit ....
   ./create_packages
   ```
 * Install the rpm or debian archive on as an addition to your zabbix-agent:
 
   ```
   rpm -Uvh noarch/zabbix-agent-extensions-<version>.noarch.rpm
   dpkg -i zabbix-agent-extensions_<version>_all.deb
   ```
 * Push release
   ```
   git tag <release-number>
   ./create_packages
   git push
   git push --tags
   ```
 * TravisCI builds and tests the release and uploads it to github

# How to configure discovery for zabbix agent
 
 * Configure disk device discovery
    * Create files: 
      (if the file does not exist, the default is used)
       * /etc/zabbix/item_zabbix_device_discovery.json<BR>
       * /etc/zabbix/item_zabbix_discovery_filesystems.json<BR>
    * Add content to include/exclude devices<BR>
      (what it does: include all devices and hardware models, after that filter out all devices and models which match to one of the python regexes) 
      ```
      /usr/bin/zabbix_discovery_devices --help
      /usr/bin/zabbix_discovery_filesystems --help
      ```
     * Test
      ```
      zabbix_agentd -t "vfs.dev.discovery"
      /usr/bin/zabbix_discovery_devices --config /etc/zabbix/item_zabbix_discovery_devices.json --debug

      zabbix_agentd -t "vfs.fs.discovery"
      /usr/bin/zabbix_discovery_filesystems --config /etc/zabbix/item_zabbix_discovery_filesystems.json --debug
      ```
 * Configure generic discovery
   * Decide to use a appname consiting of the following characters: a-zA-Z0-9. (Alphanumeric and dot characters)
   * Add file snippes to /var/run/zabbix-generic-discovery/ which look like <appname>-<anything>.json
     ```
     {
        "{#FOOOO}":"fooservice",
        "{#BAR}":"footype"
     },
     ```
   * Test the disovery by
     ```
      zabbix_agentd -t "generic.discovery[appname]"
     ```

# How to configure the zabbix server/templates

 * Open Zabbix web frontend
 * Open "Configuration" => "Templates"
 * Press button "Import"
 * Activate Linux template
   * Load "zabbix_templates/3.4/Custom - OS - Linux.xml"
   * Open template "Custom - OS - Linux" and modify the default values defined in the macros
     * Devices
       * {$DISK_HIGH_READ_IOPS_LIMIT} : alert limit for read iops/sec
       * {$DISK_HIGH_WRITE_IOPS_LIMIT} : alert limit for read iops/sec
       * {$DISK_IOPS_LIMIT_MEASURES} : how many measures need to be above the configured limits before alerting
     * Filesystems
       * {$DISK_USAGE_ABOVE_1TB_MINFREE_GBYTES} : how many gigagbytes should be free for filesystem above 1TB
       * {$DISK_USAGE_PERCENT_ALARM} : send alarm for filesystems below 1 TB on prcentage
       * {$DISK_USAGE_PERCENT_WARN} : send warning for filesystems below 1 TB on prcentage
     * {$MAXIMUM_NUMBER_RETRANSMISSIONS} : how many nfs retransmissions are ok on every measurement cycle
     * NTP
       * {$MAX_NTP_OFFSET_MS} : the maximum offset limit in milliseconds
       * {$MIN_NTP_SERVER_COUNT} : how many good ntp sources should be avaiilable, it is istrongly recommended to change the default to 2
     * {$MONITOR_LOAD_WARNING_MULT} : a multiplicator with the number of cpus for load monitoring 
     * {$MONITOR_TIMEOUT} : amount of time to complain if hosts does not provide values anymore
   * Assign template "Custom - OS - Linux" to the desired hosts and modify the default values to host specific settings
 * Activate Apache template
   * Load "zabbix_templates/Custom - Service - Apache.xml"
   * Open template "Custom - Service - Apache" and modify the default values defined in the macros
   * Assign template "Custom - Service - Apache" to the desired hosts and modify the default values to host specific settings
   
# Licence and Authors

Additional authors are very welcome - just submit your patches as pull requests.

  * Marc Schoechlin <ms@256bit.org>
  * Marc Schoechlin <marc.schoechlin@vico-research.com>
  * Marc Schoechlin <marc.schoechlin@breuninger.de> (not active anymore)
 
This software is licensed by GPLv2 - review file "LICENSE"

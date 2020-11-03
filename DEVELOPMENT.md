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
   sudo apt-get install ruby-dev build-essential debhelper devscripts rpm xalan
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


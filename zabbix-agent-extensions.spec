
Name:           zabbix-agent-extensions
Version:        1.0.36
Release:        1
License:        n/a
Group:          Monitoring
Url:            https://gitlab.brnsrv.de:peng/zabbix-agent-extensions
Requires:       zabbix-agent man
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Summary:        Addon scripts for zabbix-monitoring-agent

%description
A set of zabbix UserParameter scripts

%prep
gzip agent-scripts/man/httpjson-queryagent.8 -c > agent-scripts/man/httpjson-queryagent.8.gz

%build
mkdir -p %{buildroot}/etc/sudoers.d
echo "Defaults:zabbix !syslog" > %{buildroot}/etc/sudoers.d/zabbix
echo "zabbix ALL=(ALL) NOPASSWD: /usr/bin/zabbix_check_multipath" >> %{buildroot}/etc/sudoers.d/zabbix
chmod 0440 %{buildroot}/etc/sudoers.d/zabbix

%install
%__install -dm 755 %{buildroot}/usr/bin/
%__install -Dm 755 agent-scripts/tools/* %{buildroot}/usr/bin/
%__install -dm 755 %{buildroot}/etc/zabbix/zabbix-agent-extensions.d/
%__install -Dm 755 agent-scripts/agent-config/* %{buildroot}/etc/zabbix/zabbix-agent-extensions.d/
%__install -dm 755 %{buildroot}/usr/share/zabbix/
%__install -Dm 644 agent-scripts/check_payloads/* %{buildroot}/usr/share/zabbix/
%__install -dm 755 %{buildroot}/usr/share/man/man8/
%__install -Dm 644 agent-scripts/man/*.gz %{buildroot}/usr/share/man/man8/
%__install -dm 755 %{buildroot}/var/cache/zabbix

%clean
[ %{buildroot} != "" ] && [ %{buildroot} != "/" ] && %__rm -rf %{buildroot}
rm agent-scripts/man/httpjson-queryagent.8.gz

%files
%defattr(-,root,root)
%{_bindir}/*
%dir %{_sysconfdir}/zabbix/zabbix-agent-extensions.d/
%{_sysconfdir}/zabbix/zabbix-agent-extensions.d/*
%{_sysconfdir}/sudoers.d/zabbix
/usr/share/man/man8/
/usr/share/zabbix/
/var/cache/zabbix/

%post
chown -R zabbix:zabbix /var/cache/zabbix

#%preun
#%stop_on_removal zabbix-agentd

#%postun
#%restart_on_update zabbix-agentd

%changelog
* Mon Jun 20 2016 cjr@cruwe.de
- removed hickup on debian (softtabs in changelog)
* Mon Jun 20 2016 cjr@cruwe.de
- allow httpjson-queryagent to perform complex and recursive queries
* Mon Jun 20 2016 cjr@cruwe.de
- made jsession query use cachability
* Tue Jun 07 2016 cjr@cruwe.de
- extended with optional caching times
* Fri Jun 01 2016 cjr@cruwe.de
- extended httpjson-queryagent.rb w cache
* Fri May 20 2016 cjr@cruwe.de
- added httpjson-queryagent.rb
* Tue Dec 17 2013 ms-github.com@256bit.org
- Initial release

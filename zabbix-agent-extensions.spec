
Name:           zabbix-agent-extensions
Version:        1.0.7
Release:        1.0
License:        n/a
Group:          Monitoring
Url:            https://github.com/scoopex/zabbix-agent-extensions
Requires:       zabbix-agent


BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Summary:        Addon scripts for zabbix-monitoring-agent

%description
A set of zabbix UserParameter scripts

%prep

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

%clean
[ %{buildroot} != "" ] && [ %{buildroot} != "/" ] && %__rm -rf %{buildroot}

%files
%defattr(-,root,root)
%dir %{_bindir}
%{_bindir}/*
%dir %{_sysconfdir}/zabbix/zabbix-agent-extensions.d/
%{_sysconfdir}/zabbix/zabbix-agent-extensions.d/*
%dir %{_sysconfdir}/sudoers.d/
%{_sysconfdir}/sudoers.d/zabbix

#%preun
#%stop_on_removal zabbix-agentd

#%postun
#%restart_on_update zabbix-agentd

%changelog
* Tue Dec 17 2013 ms-github.com@256bit.org
- Initial release


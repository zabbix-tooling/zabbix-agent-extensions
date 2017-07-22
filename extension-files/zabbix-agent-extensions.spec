Name:           zabbix-agent-extensions
Version:        1.47.0
Release:        1
License:        n/a
Group:          Monitoring
Url:            https://github.com/breuninger-ecom/zabbix-agent-extensions
Requires:       zabbix-agent man
BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Summary:        Addon scripts for zabbix-monitoring-agent

%description
A set of zabbix UserParameter scripts which enhance the functionality of the zabbix-agent

%prep
gzip extension-files/man/httpjson-queryagent.8 -c > extension-files/man/httpjson-queryagent.8.gz

%build
mkdir -p %{buildroot}/etc/sudoers.d
echo "Defaults:zabbix !syslog" > %{buildroot}/etc/sudoers.d/zabbix
echo "zabbix ALL=(ALL) NOPASSWD: /usr/bin/zabbix_check_multipath" >> %{buildroot}/etc/sudoers.d/zabbix
echo "zabbix ALL=(ALL) NOPASSWD: /usr/bin//usr/bin/mailq" >> %{buildroot}/etc/sudoers.d/zabbix
chmod 0440 %{buildroot}/etc/sudoers.d/zabbix

%install
%__install -dm 755 %{buildroot}/usr/bin/
%__install -Dm 755 extension-files/tools/* %{buildroot}/usr/bin/
%__install -dm 755 %{buildroot}/etc/zabbix/zabbix-agent-extensions.d/
%__install -Dm 755 extension-files/agent-config/* %{buildroot}/etc/zabbix/zabbix-agent-extensions.d/
%__install -dm 755 %{buildroot}/usr/share/zabbix/
%__install -Dm 644 extension-files/check_payloads/* %{buildroot}/usr/share/zabbix/
%__install -dm 755 %{buildroot}/usr/share/man/man8/
%__install -Dm 644 extension-files/man/*.gz %{buildroot}/usr/share/man/man8/
%__install -dm 755 %{buildroot}/var/cache/zabbix

%clean
[ %{buildroot} != "" ] && [ %{buildroot} != "/" ] && %__rm -rf %{buildroot}
rm extension-files/man/httpjson-queryagent.8.gz

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


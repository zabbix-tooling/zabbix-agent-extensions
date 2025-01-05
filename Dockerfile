# see https://github.com/zabbix/zabbix-docker/blob/7.2/Dockerfiles/agent/ubuntu/Dockerfile
FROM zabbix/zabbix-agent:ubuntu-7.2-latest

ARG BUILD_DATE
USER 0
ADD /docker-scripts /tmp/setup
RUN chmod 755 /tmp/setup/*.sh
RUN /tmp/setup/01_phase_base.sh

ADD zabbix-agent-extensions_*_all.deb /tmp/setup
RUN /tmp/setup/04_install_agent_extensions.sh
RUN /tmp/setup/05_perform_upgrade.sh

ENTRYPOINT ["/usr/bin/docker-entrypoint.sh"]

USER 1997

CMD ["/usr/sbin/zabbix_agentd", "--foreground", "-c", "/etc/zabbix/zabbix_agentd.conf"]

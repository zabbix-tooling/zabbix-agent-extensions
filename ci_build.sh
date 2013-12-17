#!/bin/bash

set -x
set -e
rm -rf BUILDROOT i386 x86_64 noarch *.src.rpm

rpmbuild --define "_sourcedir $PWD" --define "_rpmdir $PWD" --define "_builddir $PWD" \
        --define "_srcrpmdir $PWD" --define "_speccdir $PWD" --target noarch -ba zabbix-agent-extensions.spec

find . -name "*.rpm"

rpm -qlp ./noarch/zabbix-agent-extensions*.noarch.rpm


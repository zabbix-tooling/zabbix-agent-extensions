#!/bin/bash

set -e
OPWD="$(pwd)"
rm -rf BUILDROOT i386 x86_64 noarch *.src.rpm
rm -f ${NAME}*.deb ${NAME}*.changes ${NAME}*.changes

echo creating rpm archive
rpmbuild --define "_sourcedir $PWD" --define "_rpmdir $PWD" --define "_builddir $PWD" \
        --define "_srcrpmdir $PWD" --define "_speccdir $PWD" --target noarch -ba zabbix-agent-extensions.spec
RET="$?"
if [ "$RET" != "0" ];then
   echo "ERROR: rpm build failed"
   exit 1
fi

rpm -qlp zabbix-agent-extensions*.noarch.rpm

echo creating deb archive
cd agent-scripts
debuild -i -uc -us -b -I.git -i\.git
RET="$?"
if [ "$RET" != "0" ];then
   echo "ERROR: deb build failed"
   exit 1
fi

dh_clean

cd $OPWD
find noarch -name "*noarch.rpm" -print -exec rpm -qlp {} \;

#!/bin/bash
#
OPWD="$(pwd)"

TASKS="${1:-rpm deb}"

for TASK in clean $TASKS;
do
 if [ "$TASK" = "clean" ];then
   echo "INFO: removing old build artefacts"
   rm -rf BUILDROOT i386 x86_64 packages *.src.rpm
   rm -f ${NAME}*.deb ${NAME}*.changes ${NAME}*.changes
 fi

 if [ "$TASK" = "rpm" ];then
   if (which rpmbuild &> /dev/null);then
      echo "INFO: creating rpm archive"
      rpmbuild --define "_sourcedir $OPWD" --define "_rpmdir $OPWD" --define "_builddir $OPWD" --define "_topdir $OPWD" \
              --buildroot="$OPWD/BUILDROOT" --define "_srcrpmdir $OPWD" --define "_speccdir $OPWD" --target noarch -bb packaging/zabbix-agent-extensions.spec
      RET="$?"
      if [ "$RET" != "0" ];then
         echo "ERROR: rpm build failed"
         exit 1
      fi

      mv noarch/zabbix-agent-extensions*.noarch.rpm ./
      rmdir noarch
      rpm -qlp zabbix-agent-extensions*.noarch.rpm
      RET="$?"
      if [ "$RET" != "0" ];then
         echo "ERROR: rpm build failed"
         exit 1
      fi
   else
      echo "WARN: not creating rpm archive, 'rpmbuild' tool is missing"
   fi
 fi

 if [ "$TASK" = "deb" ];then
   if (which debuild &> /dev/null);then
      echo "INFO: creating deb archive"
      cd extension-files
      debuild -i -uc -us -b -I.git -i\.git
      RET="$?"
      if [ "$RET" != "0" ];then
         echo "ERROR: deb build failed"
         exit 1
      fi

      dh_clean
   else
      echo "WARN: not creating deb archive, 'debuild' tool is missing"
   fi
 fi
done

#!/bin/bash

set -e

#not installed by default on very basic CentOS installation
PACKAGES=(
rpm-build
gcc
)

TOINSTALL=""
for p in ${PACKAGES}; do
        rpm -q ${p} > /dev/null || TOINSTALL="${TOINSTALL} ${p}"
done
[ -z "${TOINSTALL}" ] || sudo yum -y --enablerepo=base install ${TOINSTALL}

not_found(){
        echo ERROR:
        echo $1 was not found
        echo be sure you successfully ran prep.sh 
        echo and executing build.sh from the same directory as prep.sh
        exit -1
}

test -f xen-api/Makefile || not_found 'xen-api repository'
test -d javascript||not_found 'javascript catalog'

#make srpm
export CARBON_DISTFILES=..
cd xen-api

make srpm

#temporal hack - remove *.pyc and *.pyo files from installation
sed -i /usr/src/redhat/SPECS/xapi.spec  -e /.pyc/d -e /.pyo/d

rpmbuild -bb /usr/src/redhat/SPECS/xapi.spec


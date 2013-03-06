#!/bin/bash

set -e

GITREPOS=(git://github.com/xen-org/xen-api.git)

PACKAGES="vim-enhanced git tmux pkgconfig libX11 bash-completion zlib-devel pam-devel SDL e4fsprogs-libs tetex-latex"
EPEL=http://dl.fedoraproject.org/pub/epel/5/i386/epel-release-5-4.noarch.rpm

DEPURL=http://downloads.xen.org/XCP/61809c/build-deps
DEPRPMS=(blktap-2.0.90.xs726-xs6.1.0.i686.rpm
kernel-devel-3.3.0-1.xs1.6.10.34.24.i686.rpm
kernel-extra-devel-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
kernel-kdump-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
kernel-kdump-devel-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
kernel-utility-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
kernel-utility-devel-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
kernel-xen-devel-2.6.32.43-0.4.1.xs1.6.10.734.170748.i686.rpm
libev-4.04-1.i686.rpm
ocaml-3.12.1.ocamlspotter-unknown.i686.rpm
ocaml-bitstring-2.0.3-1.i686.rpm
ocaml-bitstring-devel-2.0.3-1.i686.rpm
ocaml-camlp4-3.12.1.ocamlspotter-unknown.i686.rpm
ocaml-debuginfo-3.12.1.ocamlspotter-unknown.i686.rpm
ocaml-findlib-1.2.6-unknown.i686.rpm
ocaml-findlib-devel-1.2.6-unknown.i686.rpm
ocaml-getopt-20040811-unknown.i686.rpm
ocaml-getopt-debuginfo-20040811-unknown.i686.rpm
ocaml-getopt-devel-20040811-unknown.i686.rpm
ocaml-lwt-2.3.1-2.i686.rpm
ocaml-lwt-devel-2.3.1-2.i686.rpm
ocaml-obus-1.1.3-3.i686.rpm
ocaml-obus-devel-1.1.3-3.i686.rpm
ocaml-ounit-1.1.0-3.i686.rpm
ocaml-ounit-devel-1.1.0-3.i686.rpm
ocaml-react-0.9.2-2.i686.rpm
ocaml-react-devel-0.9.2-2.i686.rpm
ocaml-text-0.5-3.i686.rpm
ocaml-text-devel-0.5-3.i686.rpm
ocaml-type-conv-3.0.1-unknown.i686.rpm
ocaml-type-conv-debuginfo-3.0.1-unknown.i686.rpm
ocaml-xmlm-1.0.2-unknown.i686.rpm
ocaml-xmlm-debuginfo-1.0.2-unknown.i686.rpm
ocaml-xmlm-devel-1.0.2-unknown.i686.rpm
omake-0.9.8.6-unknown.i686.rpm
xapi-client-devel-0.2-5227.i686.rpm
xapi-datamodel-devel-0.2-5227.i686.rpm
xapi-libs-devel-0.1-858.i686.rpm
xapi-rrd-devel-0.2-5227.i686.rpm
xen-devel-4.1.3-1.6.10.513.23557.i686.rpm
xen-device-model-1.6.10-54.7533.i686.rpm
xen-device-model-debuginfo-1.6.10-54.7533.i686.rpm
xen-hypervisor-4.1.3-1.6.10.513.23557.i686.rpm
xen-tools-4.1.3-1.6.10.513.23557.i686.rpm
)

# Add EPEL
rpm -q epel-release > /dev/null || sudo rpm -Uvh ${EPEL}

# Install dev tools (if make is installed, we've already installed this group)
which make > /dev/null || sudo yum -y --enablerepo=base groupinstall "Development Tools"

# Install EPEL/base repo dependencies
TOINSTALL=""
for p in ${PACKAGES}; do
	rpm -q ${p} > /dev/null || TOINSTALL="${TOINSTALL} ${p}"
done
[ -z "${TOINSTALL}" ] || sudo yum -y --enablerepo=base install ${TOINSTALL}

# Download and install RPM deps
TOINSTALL=""
mkdir -p ext-rpms
for dep in ${DEPRPMS[*]}; do
	# Download dep iff we haven't installed id, and we haven't already downloaded it
	if ([ ! $(rpm -q $(basename ${dep} .rpm) > /dev/null) ] && [ ! -f ext-rpms/${dep} ]); then
		wget -P ext-rpms ${DEPURL}/${dep}
		TOINSTALL="${TOINSTALL} ext-rpms/${dep}"
	else
		# But we may still need to install it, even if we didn't redownload it
		rpm -q $(basename ${dep} .rpm) > /dev/null || TOINSTALL="${TOINSTALL} ${dep}"
	fi
done
[ -z "${TOINSTALL}" ] || sudo rpm -Uvh ${TOINSTALL}

# Clone git repos
for repo in ${GITREPOS[*]}; do
	git clone ${repo} 2> /dev/null || true
	cd $(basename ${repo} .git)
	git checkout xcp-tampa 2> /dev/null
	cd ..
done

# Add CentOS string to /etc/issue
grep -i centos /etc/issue > /dev/null || sudo su -c 'echo CentOS >> /etc/issue'

# Done, write stamp
touch .prep.stamp

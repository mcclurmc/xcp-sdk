XCP SDK Scripts
===============

This repository is for creating XCP SDK VMs. The idea is that you can download
this repo, run the prepare script, and you'll have a system that's ready to
build XCP's xen-api.

Currently, this script downloads a number of build dependencies from xen.org,
installs the EPEL yum repo, installs build dependencies from EPEL and CentOS
base repos, and clones xen-api from github.com/xen-org. Eventually, this script
will expand to let you build other XCP components such as the kernel and
hypervisor, and hopefully will let you rebuild RPMs.

Requirements
------------

This script should work on any CentOS 5.7 system, but I've only tested it on
XCP 1.6 running in VirtualBox.

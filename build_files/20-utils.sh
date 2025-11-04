#!/bin/bash

set -ouex pipefail

### Install packages

# Domain Joining
dnf5 -y install adcli freeipa-client oddjob-mkhomedir samba-common-tools samba-w
inbind sssd-ad sssd-ipa libsss_autofs libsss_sudo sssd-nfs-idmap


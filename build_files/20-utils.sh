#!/bin/bash

set -ouex pipefail

### Install packages

# Domain Joining
dnf5 -y install adcli freeipa-client oddjob-mkhomedir samba-common-tools samba-winbind sssd-ad sssd-ipa sssd-ldap libsss_autofs libsss_sudo sssd-nfs-idmap


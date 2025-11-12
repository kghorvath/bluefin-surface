#!/bin/bash

set -ouex pipefail

### Install packages

# Editors
dnf5 -y install emacs neovim

# Domain Joining
dnf5 -y install adcli oddjob-mkhomedir samba-common-tools samba-winbind sssd-ad sssd-ipa sssd-ldap libsss_autofs libsss_sudo sssd-nfs-idmap

# Utilities
dnf5 -y install stow htop

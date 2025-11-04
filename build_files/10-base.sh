#!/bin/bash

set -ouex pipefail

### Install packages

# General Packages
dnf5 -y install stow terminus-fonts-console

# Editors
dnf5 -y install emacs neovim

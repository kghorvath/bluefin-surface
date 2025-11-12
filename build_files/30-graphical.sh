#!/bin/bash

set -ouex pipefail

### Install packages

# Terminal Emulators
dnf5 -y copr enable scottames/ghostty
dnf5 -y install ghostty
dnf5 -y copr disable scottames/ghostty

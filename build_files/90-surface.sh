#!/bin/bash

set -ouex pipefail

### Surface Kernel Modifications

# Remove Existing Kernel
for pkg in kernel kernel-core kernel-modules kernel-modules-core kernel-modules-extra; do
    rpm --erase $pkg --nodeps
done

# Fetch Kernel RPMS
mkdir /tmp/kernel-rpms
skopeo copy --retry-times 3 docker://ghcr.io/bazzite-org/kernel-bazzite:latest-f"$(rpm -E %fedora)"-x86_64 dir:/tmp/
KERNEL_TARGZ=$(jq -r '.layers[].digest' </tmp/kernel-rpms/manifest.json | cut -d : -f 2)
tar -xvzf /tmp/"$KERNEL_TARGZ" -C /tmp/kernel-rpms/

# Install Kernel
dnf5 --setopt=disable_excludes=* -y install \
    /tmp/kernel-rpms/kernel-[0-9]*.rpm \
    /tmp/kernel-rpms/kernel-core-*.rpm \
    /tmp/kernel-rpms/kernel-modules-*.rpm > /tmp/dnf_log.txt

cat /tmp/dnf_log.txt

dnf5 versionlock add kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra

#dnf5 -y install /tmp/akmods/kmods/*kvmfr*.rpm

curl --retry 3 -Lo /etc/yum.repos.d/linux-surface.repo \
        https://pkg.surfacelinux.com/fedora/linux-surface.repo

#Temp change to F42 baseurl
sed -i 's/\$releasever/42/g' /etc/yum.repos.d/linux-surface.repo

SURFACE_PACKAGES=(
    iptsd
    libcamera
    libcamera-tools
    libcamera-gstreamer
    libcamera-ipa
    pipewire-plugin-libcamera
)

dnf5 -y install --skip-unavailable \
    "${SURFACE_PACKAGES[@]}"

dnf5 -y swap \
    libwacom-data libwacom-surface-data

dnf5 -y swap \
    libwacom libwacom-surface

tee /usr/lib/modules-load.d/ublue-surface.conf << EOF
# Only on AMD models
pinctrl_amd

# Surface Book 2
pinctrl_sunrisepoint

# For Surface Laptop 3/Surface Book 3
pinctrl_icelake

# For Surface Laptop 4/Surface Laptop Studio
pinctrl_tigerlake

# For Surface Pro 9/Surface Laptop 5
pinctrl_alderlake

# For Surface Pro 10/Surface Laptop 6
pinctrl_meteorlake

# Only on Intel models
intel_lpss
intel_lpss_pci

# Add modules necessary for Disk Encryption via keyboard
surface_aggregator
surface_aggregator_registry
surface_aggregator_hub
surface_hid_core
8250_dw

# Surface Laptop 3/Surface Book 3 and later
surface_hid
surface_kbd
EOF

KERNEL_SUFFIX=""

QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

#!/bin/bash
: '
Make a bootable arm image
./make-arch-arm32.sh /dev/<sd-card>
 '

set -eo pipefail

DRIVE=$1

read -p "Will write on ${DRIVE}, continue? (Y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

read -p "Enter default user: " USER_NAME
read -p "Enter user password: " USER_PASSWORD
read -p "Enter root password: " ROOT_PASSWORD

pushd $(mktemp -d)
sudo dd if=/dev/zero of=${DRIVE} bs=1M count=8
wget https://k-space.ee.armbian.com/archive/odroidxu4/archive/Armbian_24.11.1_Odroidxu4_bookworm_current_6.6.60_minimal.img.xz -O armbian.img.xz
xz --decompress armbian.img.xz
mkdir root

# Offset should be dynamically calculated with fdisk -l armbian.img.xz,
# it's block size * start of first partition: 512 * 8192 = 4194304
sudo mount -v -o offset=4194304 -t auto armbian.img root

sudo bash -c "cat > root/root/.not_logged_in_yet" <<EOL
# Network Settings
PRESET_NET_CHANGE_DEFAULTS="1"
## Ethernet
PRESET_NET_ETHERNET_ENABLED="1"
## WiFi
PRESET_NET_WIFI_ENABLED="0"
PRESET_CONNECT_WIRELESS="n"
## Static IP
PRESET_NET_USE_STATIC="0"

# System
SET_LANG_BASED_ON_LOCATION="y"
PRESET_LOCALE="en_US.UTF-8"
PRESET_TIMEZONE="Etc/UTC"

# Root
PRESET_ROOT_PASSWORD="${ROOT_PASSWORD}"
PRESET_ROOT_KEY="https://github.com/ldenefle.keys"

# User
PRESET_USER_NAME="lucas"
PRESET_USER_PASSWORD="${USER_PASSWORD}"
PRESET_USER_KEY="https://github.com/ldenefle.keys"
PRESET_DEFAULT_REALNAME="Default user"
PRESET_USER_SHELL="bash"
EOL
sudo umount root

# Write image on sd card
sudo dd if=armbian.img of=/dev/sdc bs=4M conv=fsync status=progress

popd

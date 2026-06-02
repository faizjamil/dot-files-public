#!/usr/bin/env bash
# RUN FROM ARCH INSTALLATION MEDIA, NOT FROM THE INSTALLED SYSTEM
# install by downloading this script and running it with bash

# curl -s -L "https://raw.githubusercontent.com/faizjamil/dot-files-public/main/base_arch_packages_install.sh" | bash
echo "Backing up existing mirrorlist to /etc/pacman.d/mirrorlist.backup"
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
echo "Getting updated list of best mirrors"
reflector --country US,CA --protocol https --latest 20 --sort age --save /etc/pacman.d/mirrorlist
echo "Updated mirrorlist saved to /etc/pacman.d/mirrorlist"

echo "Installing base packages to /mnt..."
pacstrap -K /mnt base base-devel git linux-firmware intel-ucode nano man-db man-pages e2fsprogs dosfstools exfatprogs
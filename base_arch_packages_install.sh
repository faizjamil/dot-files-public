#!/bin/bash
echo "Getting updated list of best mirrors"
reflector --country US,CA --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
echo "Updated mirrorlist saved to /etc/pacman.d/mirrorlist"

echo "Installing base packages to /mnt..."
pacstrap -K /mnt base base-devel git linux-firmware intel-ucode nano man-db man-pages e2fsprogs dosfstools exfatprogs
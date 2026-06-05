# Install Arch Linux

This is for my own records, if you are reading this you likely won't find much use for the following text.

For the most part if you want to install arch, [read the wiki](https://wiki.archlinux.org/title/Installation_guide) and if you want secure boot [read CachyOS's page on it.](https://wiki.cachyos.org/configuration/secure_boot_setup/)

I'm only noting down any deviations or customizations from the [Arch Wiki installation guide](https://wiki.archlinux.org/title/Installation_guide) I make for my particular arch setup.

## Pre-install

In the live boot environment execute the following command to set the font to something readable (for me)

```sh
setfont ter-132b --double
```

### Partitions

Create three partitions

1. 1 GiB ESP
2. 4 GiB Swap Partition
3. Use remaining space for Linux x86-64 root (filesystem type in cfdisk)

## Installation

Run the folliowing command to run a script to automate the following steps.

```sh
curl -s -L "https://raw.githubusercontent.com/faizjamil/dot-files-public/main/base_arch_packages_install.sh" | bash
```

### Select mirrors using reflector

Run this command, confirm the output, and run it again with the flag `--save /etc/pacman.d/mirrorlist`

```sh
reflector --country US,CA --protocol https --latest 20 --sort age 
```

This grabs the 20 most recently synced HTTPS mirrors in the US and CA.

### Install essential packages

****
Per [the script in this repo](base_arch_packages_install.sh)

```sh
pacstrap -K /mnt base base-devel linux linux-firmware intel-ucode micro nano man-db man-pages git curl networkmanager
```

[Look up these packages](https://archlinux.org/packages/) if you don't know what they do but they should be self-explanatory

After installing essential packages, reboot into BIOS and enter Setup Mode to setup secure boot.

## Configure

For time setup run `hwclock --systohc --local` and/or `timedatectl set-local-rtc 1 --adjust-system-clock` (outside chroot)

For setting up `systemd-boot`

Note: `esp` here is a placeholder for the path to the EFI System Parition

1. Run `bootctl install`
2. Copy [loader.conf](.config/systemd-boot/loader.conf) to `esp/loader`
3. Get the UUID of root partition using `blkid` and paste the UUID into `arch.conf`
4. Copy [arch.conf](.config/systemd-boot/arch.conf) to `esp/loader/entries`
5. Setup Secure Boot using `sbctl` taking note to execute the following command for signing **the bootloader specifically** to allow for `sbctl`'s pacman hook to run and auto-sign on a bootloader update. You still need to sign the other required files as per `sbctl`'s docs

  ```sh
  sbctl sign -s -o /usr/lib/systemd/boot/efi/systemd-bootx64.efi.signed /usr/lib/systemd/boot/efi/systemd-bootx64.efi
  ```
  
6. Reboot and enable Secure Boot in UEFI settings.

## Additional notes

- [Enable the `multilib` repo](https://wiki.archlinux.org/title/Official_repositories#multilib) **before** running `bootstrap.sh`
- Use [arch_create_user.txt](arch_create_user.txt) to create a non-root user, setup sudo access, and disable the root user
- Start any needed services such as lightdm, networkmanager, etc. (add more later)
- Enable slick greeter by adding the line `greeter-session=lightdm-slick-greeter` to /etc/lightdm/lightdm.conf

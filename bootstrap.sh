#!/usr/bin/env bash


checkDistro() {
    DISTRO=""
    if [[ -e "/etc/debian-release"]]
    then
        # we know it's debian based
        if [[ -e "/etc/lsb-release"]]
        then
            if [[-e "/usr/bin/wslinfo"]]
            then
                DISTRO="ubuntu_wsl"
            else
                DISTRO="ubuntu"
            fi
        else
            DISTRO="debian"
        fi
    fi
    return $DISTRO
        
}
# look here for how to detect different distros
# this file will be used to aid setting up a system
# for now i will simply be making symlinks to the dotfiles in this repo as needed
# the following creates a symlink to my .zshrc file
# the script will assume the directory structure indicated in the command below for all other operations
# util-linux-user does not exist on ubuntu
# ubuntu: steam-installer smplayer smplayer-themes redshift fonts-liberation libdvd-pkg ttf-mscorefonts-installer
# setup installation of https://github.com/raphaelquintao/QRedshiftCinnamon
PACKAGES_TO_INSTALL=(python3 zsh util-linux-user fzf bat curl)
# if not ubuntu wsl we add gui packages, else we just install as is
# PACKAGES_TO_INSTALL=(code vlc steam python3 zsh wget filezilla keepassxc qbittorrent util-linux-user smplayer.x86_64 smplayer-themes.x86_64 terminator redshift-gtk fzf flatpak bat liberation-fonts libdvdcss curl cabextract xorg-x11-font-utils fontconfig mullvad-vpn)

# installing packages
# TODO: script installation of packages based on package managers, account for yum, rpm, and pacman
# include installation for mkvtoolnix and mediainfo
# include steps to install docker desktop instead of docker CE
# PACKAGES_TO_INSTALL=
# for fedora systems
echo "Upgrading packages..."
sudo dnf -y upgrade --refresh
echo "Adding Flathub remote to Flatpak"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "Flathub remote added to Flatpak"
echo "Enabling the Free and Nonfree RPM Fusion repos"
sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y install https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf -y groupupdate core
sudo dnf install -y rpmfusion-free-release-tainted
sudo dnf install -y rpmfusion-nonfree-release-tainted 
sudo dnf install -y dnf-plugins-core
echo "rpmfusion repos enabled"
echo "Updating firmware for available devices"
sudo fwupdmgr get-devices 
sudo fwupdmgr refresh --force 
sudo fwupdmgr get-updates 
sudo fwupdmgr update

echo "Installing Zoom from flatpak"
flatpak install flathub us.zoom.Zoom
# echo "Installing Zoom (rpm)"
# wget https://zoom.us/client/latest/zoom_x86_64.rpm
# sudo dnf -y install https://zoom.us/client/latest/zoom_x86_64.rpm
echo "Zoom flatpak installed"
echo "Installing Slack from flathub"
flatpak install flathub com.slack.Slack
echo "Slack flatpak installed"
echo "Installing Discord from flatpak"
flatpak install flathub com.discordapp.Discord
echo "Discord flatpak installed"
echo "Installing ATLauncher"
sudo dnf -y install https://atlauncher.com/download/rpm
echo "Installed ATLauncher"
echo "To install overGrive (Google Drive client) go to https://www.overgrive.com/"
read -n 1 -p "Press any key once that's complete"
echo "Adding Microsoft Repo for VS Code"
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
echo "Adding repo for mullvad VPN"
# Fedora 41 and newer
# Add the Mullvad repository server to dnf
sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
sudo dnf -y upgrade --refresh
for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
do 
    echo Installing ${PACKAGE}  
    sudo dnf install -y ${PACKAGE}
done
echo ${PACKAGES_TO_INSTALL} installed
echo "Installing packages for gstreamer applications"
sudo dnf install -y gstreamer1-plugins-{bad-\*,good-\*,base} gstreamer1-plugin-openh264 gstreamer1-libav --exclude=gstreamer1-plugins-bad-free-devel
sudo dnf install -y lame\* --exclude=lame-devel
sudo dnf group upgrade -y --with-optional Multimedia --allowerasing
echo "Packages for gstreamer apps installed"
echo "Installing packages needed by some apps for sound and video"
sudo dnf groupupdate -y sound-and-video
echo "Sound and video package group installed"
echo "Installing OpenH264"
sudo dnf config-manager -y --set-enabled fedora-cisco-openh264
sudo dnf install -y gstreamer1-plugin-openh264 mozilla-openh264
echo "OpenH264 installed, ensure it's enabled in Firefox"
echo "Running another upgrade with support for additional codecs"
sudo dnf group upgrade -y --with-optional Multimedia --allowerasing
echo "Multimedia packages installed"
echo "Installing Microsoft fonts"
sudo dnf install -y https://downloads.sourceforge.net/project/mscorefonts2/rpms/msttcore-fonts-installer-2.6-1.noarch.rpm
echo "Microsoft fonts installed"
echo "Installing oh-my-zsh and removing .zshrc from home directory"
rm ~/.zshrc
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
echo "oh-my-zsh installed"
echo "Installing fnm"
# installs fnm 
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
echo "fnm installed"
# create symlink to .gitconfig and .zshrc
echo "creating symlink for .zshrc"

# if dnf is on system
ln -s ~/repos/dot-files-public/.dotfiles/.zshrc_dnf ~/.zshrc
echo "symlink to .zshrc created"
# else, use deb zshrc
source ~/.zshrc
# install latest node LTS version
echo "Installing latest node.js LTS version"
fnm install --lts
echo "Node LTS installed"
echo "Installing deno"
curl -fsSL https://deno.land/install.sh | bash -s -- --yes --no-modify-path
echo "Deno installed"
# create symlink to .gitconfig and .zshrc
echo "creating symlink to .gitconfig"

# ln -s ~/repos/dot-files/.dotfiles/.zshrc_apt ~/.zshrc
ln -s ~/repos/dot-files-public/.dotfiles/.gitconfig ~/.gitconfig
echo "creating symlinks for configs"
ln -s ~/repos/dot-files-public/.config/redshift ~/.config/redshift
ln -s ~/repos/dot-files-public/.config/terminator ~/.config/terminator
echo "symlinks created"
echo "Restoring Cinnamon config(s)"
dconf load /org/cinnamon/ < /cinnamon_config/dconf-settings
echo "Cinnamon config(s) restored"
echo "Cleaning up .rpm files"
rm *.rpm
echo "Clean up complete"
echo "setting .ssh directory perms to 700"
chmod -R 700 ~/.ssh
echo "perms set"
# echo "Make linux use local time"
# timedatectl set-local-rtc 1 --adjust-system-clock
# echo "Linux uses local time, time should be fine on windows and linux now"
# TO UNDO THE ABOVE: timedatectl set-local-rtc 0 --adjust-system-clock
echo "Setup complete, enjoy your Fedora system :)"
echo "Make sure to reboot your system!"
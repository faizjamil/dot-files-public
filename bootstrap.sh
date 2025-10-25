#!/usr/bin/env bash

OS=$(uname -s)
# echo $OS

checkDistro() {
    DISTRO=""
    if [[ $OS = "Linux" ]]
    then
      if [[ -f "/etc/debian_version" ]]
        then
          # echo "debian"
          # we know it's debian based
          if [[ -f "/etc/lsb-release" ]]
          then
            if [[ -f "/usr/bin/wslinfo" ]]
            then
                DISTRO="ubuntu_wsl"
            else
                DISTRO="ubuntu"
            fi
          else
            DISTRO="debian"
          fi
        elif [[ -f "/etc/fedora-release" ]]
        then
          DISTRO="fedora"
        else
          DISTRO="unknown"
        fi
    elif [[ $OS = "Darwin" ]]
    then
      DISTRO="macOS"
    fi

    echo $DISTRO

}
PACKAGES_TO_INSTALL=(git python3 zsh fzf bat)
if [[ ! (-f "/bin/curl" || -f "/usr/bin/curl") ]]
then
  PACKAGES_TO_INSTALL+=(curl)
fi
if [[ ! (-f "/bin/wget" || -f "/usr/bin/wget") ]]
then
  PACKAGES_TO_INSTALL+=(wget)
fi
DISTRO=$(checkDistro)
if [[ ! $DISTRO = "ubuntu_wsl" ]]
then
  PACKAGES_TO_INSTALL+=(code vlc steam filezilla qbittorrent terminator mullvad-vpn)
  if [[ $DISTRO = "ubuntu" || $DISTRO = "debian" ]]
  then 
    PACKAGES_TO_INSTALL+=(smplayer smplayer-themes redshift fonts-liberation ttf-mscorefonts-installer)
    echo "Adding repo for VS Code"
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections
    echo "VS Code repo added"
    echo "Adding repo for Mullvad"
    
    # Download the Mullvad signing key
    sudo curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

    # Add the Mullvad repository server to apt
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main" | sudo tee /etc/apt/sources.list.d/mullvad.list
    echo "Mullvad repo added"
    echo "Adding repo for Firefox"
    # from: https://support.mozilla.org/en-US/kb/install-firefox-linux#w_install-firefox-deb-package-for-debian-based-distributions-recommended
    # 1. Create a directory to store APT repository keys if it doesn't exist: 
    sudo install -d -m 0755 /etc/apt/keyrings 
    # 2. Import the Mozilla APT repository signing key: 
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    # 3. The fingerprint should be 35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3. You may check it with the following command: 
    gpg -n -q --import --import-options import-show /etc/apt/keyrings/packages.mozilla.org.asc | awk '/pub/{getline; gsub(/^ +| +$/,""); if($0 == "35BAA0B33E9EB396F59CA838C0BA5CE6DC6315A3") print "\nThe key fingerprint matches ("$0").\n"; else print "\nVerification failed: the fingerprint ("$0") does not match the expected one.\n"}'
    # 4. Next, add the Mozilla APT repository to your sources.list: 
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    # 5. Configure APT to prioritize packages from the Mozilla repository: 
    echo '
    Package: *
    Pin: origin packages.mozilla.org
    Pin-Priority: 1000
    ' | sudo tee /etc/apt/preferences.d/mozilla 
    # 6. Update your package list, and install firefox
    sudo apt-get remove -y firefox
    sudo apt-get update
    sudo apt-get install -y firefox
    echo "Updating firmware for available devices"
    sudo fwupdmgr get-devices 
    sudo fwupdmgr refresh --force 
    sudo fwupdmgr get-updates 
    sudo fwupdmgr update
    echo "Upgrading existing packages"
    sudo apt-get -y upgrade
    echo "Existing packages upgraded"

    for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
    do 
        echo Installing ${PACKAGE}  
        sudo apt-get -y install  ${PACKAGE}
    done
    # install ATLauncher
    cd /tmp
    echo "Installing ATLauncher"
    wget -O atlauncher.deb https://atlauncher.com/download/deb
    sudo apt-get install -y ./atlauncher.deb
    echo "ATLauncher installed"
    # install FTB APP
    # deb url: https://piston.feed-the-beast.com/app/ftb-app-linux-1.28.2-amd64.deb
    echo "Installing FTB App"
    wget -O ftb.deb https://piston.feed-the-beast.com/app/ftb-app-linux-1.28.2-amd64.deb
    sudo apt-get install -y ./ftb.deb
    echo "FTB App installed"
    echo "removing unneeded packages"
    sudo apt-get remove -y transmission-gtk mintchat thunderbird thingy
    echo "thunderbird, transmission, matrix, and thingy have been removed"
  elif [[ $DISTRO = "fedora" ]]
  then
    PACKAGES_TO_INSTALL+=(util-linux-user smplayer.x86_64 smplayer-themes.x86_64 redshift-gtk liberation-fonts cabextract xorg-x11-font-utils fontconfig mullvad-vpn)
    
    echo "Enabling the Free and Nonfree RPM Fusion repos"
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf groupupdate -y core
    sudo dnf install -y rpmfusion-free-release-tainted
    sudo dnf install -y rpmfusion-nonfree-release-tainted 
    sudo dnf install -y dnf-plugins-core
    echo "rpmfusion repos enabled"
    echo "Updating firmware for available devices"
    sudo fwupdmgr get-devices 
    sudo fwupdmgr refresh --force 
    sudo fwupdmgr get-updates 
    sudo fwupdmgr update
    echo "Adding Microsoft Repo for VS Code"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    echo "Adding repo for mullvad VPN"
    # Fedora 41 and newer
    # Add the Mullvad repository server to dnf
    sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
    echo "Repo for mullvad VPN added"
    echo "Upgrading existing packages"
    sudo dnf upgrade -y --refresh
    echo "Existing packages upgraded"
    for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
    do 
        echo Installing ${PACKAGE}  
        sudo dnf install -y ${PACKAGE}
    done
    echo ${PACKAGES_TO_INSTALL} installed
    echo "Installing ATLauncher"
    sudo dnf install -y https://atlauncher.com/download/rpm
    echo "Installed ATLauncher"
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
  fi
  cd ~/repos/dot-files-public

  echo "To install overGrive (Google Drive client) go to https://www.overgrive.com/"
  read -n 1 -p "\n Press any key once that's complete \n"
  echo "Adding Flathub remote to Flatpak"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  echo "Flathub remote added to Flatpak"
  echo "Installing Zoom flatpak"
  flatpak install -y --noninteractive flathub us.zoom.Zoom
  echo "Zoom flatpak installed"
  echo "Installing Slack flathub"
  flatpak install -y --noninteractive flathub com.slack.Slack
  echo "Slack flatpak installed"
  echo "Installing Discord flatpak"
  flatpak install -y --noninteractive flathub com.discordapp.Discord
  echo "Discord flatpak installed"
  echo "Installing Flatseal"
  flatpak install -y --noninteractive flathub com.github.tchx84.Flatseal
  echo "Flatseal installed"
  echo "Installing KeepassXC flatpak"
  flatpak install --user -y --noninteractive flathub org.keepassxc.KeePassXC
  echo "KeepassXC flatpak installed"
else
    # assume is ubuntu WSL
    sudo apt-get update
    echo "Upgrading existing packages"
    sudo apt-get -y upgrade
    for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
    do 
        echo Installing ${PACKAGE}  
        sudo apt-get -y install  ${PACKAGE}
    done
fi

echo "Installing oh-my-zsh and removing .zshrc from home directory"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
echo "oh-my-zsh installed"
rm ~/.zshrc

# if dnf is on system
if [[ $DISTRO = "ubuntu_wsl" || $DISTRO = "ubuntu" ]]
then
  ln -s ~/repos/dot-files-public/.dotfiles/.zshrc_apt ~/.zshrc
  echo "symlink to .zshrc created"
elif [[ $DISTRO = "fedora" ]]
then
  ln -s ~/repos/dot-files-public/.dotfiles/.zshrc_dnf ~/.zshrc
  echo "symlink to .zshrc created"
else 
  echo "NOT ON UBUNTU OR FEDORA BASED SYSTEM, NOT SYMLINKING ZSHRC"
fi
echo "Installing deno"
curl -fsSL https://deno.land/install.sh | bash -s -- --yes --no-modify-path
echo "Deno installed"
# installs fnm 
echo "Installing fnm"
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
echo "fnm installed"
# install latest node LTS version
echo "Installing latest node.js LTS version"
cd ~/.local/share/fnm/
./fnm install --lts
echo "Node LTS installed"
cd ~/repos/dot-files-public
# create symlink to .gitconfig
echo "creating symlink to configs"
ln -s ~/repos/dot-files-public/.dotfiles/.gitconfig ~/.gitconfig
ln -s ~/repos/dot-files-public/.config/redshift ~/.config/redshift
ln -s ~/repos/dot-files-public/.config/terminator ~/.config/terminator
echo "symlinks created"
# echo "Restoring Cinnamon config(s)"
# cd ./cinnamon_config
# dconf load /org/cinnamon/ < dconf-settings-mint
# echo "Cinnamon config(s) restored"

echo "Make linux use local time"
timedatectl set-local-rtc 1 --adjust-system-clock
# echo "Linux uses local time, time should be fine on windows and linux now"
# TO UNDO THE ABOVE: timedatectl set-local-rtc 0 --adjust-system-clock
echo "Setup complete, enjoy your system :)"
echo "Make sure to reboot your system!"
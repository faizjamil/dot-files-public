#!/usr/bin/env bash

# NOTE: WE ARE INSTALLING LIBERATION FONTS TO PREVENT ANY FONT ISSUES WITH STEAM

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
    elif [[ -f "/etc/arch-release" ]]
    then
      DISTRO="arch"
    else
      DISTRO="unknown"
    fi
  elif [[ $OS = "Darwin" ]]
  then
    DISTRO="macOS"
  fi
  echo $DISTRO
}

PACKAGES_TO_INSTALL=(zsh fzf bat eza tealdeer ripgrep micro)
if [[ ! (-f "/bin/curl" || -f "/usr/bin/curl") ]]
then
  PACKAGES_TO_INSTALL+=(curl)
fi
if [[ ! (-f "/bin/wget" || -f "/usr/bin/wget") ]]
then
  PACKAGES_TO_INSTALL+=(wget)
fi
if [[ ! (-f "/bin/git" || -f "/usr/bin/git") ]]
then
  PACKAGES_TO_INSTALL+=(git)
fi
if [[ ! (-f "/bin/gzip" || -f "/usr/bin/gzip") ]]
then
  PACKAGES_TO_INSTALL+=(gzip)
fi

DISTRO=$(checkDistro)
if [[ ! $DISTRO = "ubuntu_wsl" ]]
then
  PACKAGES_TO_INSTALL+=(firefox vlc steam filezilla qbittorrent konsole mullvad-vpn)
  if [[ $DISTRO = "ubuntu" || $DISTRO = "debian" ]]
  then 
    PACKAGES_TO_INSTALL+=(code redshift fonts-liberation fonts-atkinson-hyperlegible-next fonts-atkinson-hyperlegible fonts-noto fontconfig)
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
    # we are using firefox from official mozilla repo
    echo "removing unneeded packages"
    sudo apt-get remove -y firefox transmission-gtk mintchat thunderbird thingy rhythmbox sticky hypnotix
    echo "firefox, thunderbird, transmission, matrix, thingy, rhythmbox, sticky, and hypnotix have been removed"
    echo "removing libreoffice"
    sudo apt-get remove -y --purge "libreoffice*"
    sudo apt-get clean -y
    sudo apt-get autoremove -y
    # 6. Update your package list
    sudo apt-get update


    echo "Upgrading existing packages"
    sudo apt-get upgrade -y
    echo "Existing packages upgraded"

    echo "Installing all specified native packages"

    for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
    do 
        echo "Installing ${PACKAGE}"  
        sudo apt-get -y install ${PACKAGE}
        echo "${PACKAGE} installed"  
    done

    # cd /tmp
    # install FTB APP
    # deb url: https://piston.feed-the-beast.com/app/ftb-app-linux-1.28.2-amd64.deb
    echo "All specified native packages installed"

  elif [[ $DISTRO = "fedora" ]]
  then
    
    PACKAGES_TO_INSTALL+=(util-linux-user redshift-gtk liberation-fonts cabextract xorg-x11-font-utils fontconfig google-noto-fonts-all atkinson-hyperlegible-mono-fonts atkinson-hyperlegible-next-fonts)

    echo "Enabling the Free and Nonfree RPM Fusion repos"
    sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    sudo dnf groupupdate -y core
    sudo dnf install -y rpmfusion-free-release-tainted
    sudo dnf install -y rpmfusion-nonfree-release-tainted 
    sudo dnf install -y dnf-plugins-core
    echo "rpmfusion repos enabled"

    
    echo "Adding Microsoft Repo for VS Code"
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
    echo "Repo for VS Code added"

    echo "Adding repo for mullvad VPN"
    # Fedora 41 and newer
    # Add the Mullvad repository server to dnf
    sudo dnf config-manager addrepo --from-repofile=https://repository.mullvad.net/rpm/stable/mullvad.repo
    echo "Repo for mullvad VPN added"
    echo "Removing libreoffice"
    sudo dnf group remove -y libreoffice
    sudo dnf remove -y libreoffice*
    echo "libreoffice removed"
    echo "Removing pre-installed firefox"
    sudo dnf remove -y firefox
    echo "firefox removed, will be installed from official mozilla repo"
    echo "adding firefox repo from mozilla"
    sudo dnf config-manager addrepo --id=mozilla --set=baseurl=https://packages.mozilla.org/rpm/firefox --set=gpgkey=https://packages.mozilla.org/rpm/firefox/signing-key.gpg --set=gpgcheck=1 --set=repo_gpgcheck=0 --set=priority=10
    sudo dnf makecache --refresh
    echo "Repo for firefox added, will be installed from there"
    echo "Upgrading existing packages"
    sudo dnf upgrade -y --refresh
    echo "Existing packages upgraded"

    echo "Installing all specified native packages"
    for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
    do 
        echo "Installing ${PACKAGE}"  
        sudo dnf install -y ${PACKAGE}
        echo "${PACKAGE} installed"  
    done
    
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
    echo "All specified native packages installed"
  elif [[ $DISTRO = "arch" ]]
  then
    PACKAGES_TO_INSTALL_ARCH+=(zsh fzf bat eza tealdeer ripgrep micro fwupd vlc-plugins-extra lightdm lightdm-slick-greeter cinnamon xed xviewer xreader nftables ttf-croscore ttf-noto otf-atkinson-hyperlegible unzip flatpak ttf-liberation mesa vulkan-radeon lib32-mesa lib32-vulkan-radeon pacman-contrib reflector chrony tuned sbctl earlyoom firefox vlc steam filezilla qbittorrent konsole mullvad-vpn)
    echo "Installing all specified native packages"
    for PACKAGE in "${PACKAGES_TO_INSTALL_ARCH[@]}"
    do 
        echo "Installing ${PACKAGE}"  
        sudo pacman -S ${PACKAGE}
        echo "${PACKAGE} installed"  
    done
    echo "All specified native packages installed"
    echo "Enabling all needed services"
    # we are enabling lightdm, nftables, and cups (for printing) with its pdf backend
    sudo systemctl enable lightdm.service
    sudo systemctl enable nftables.service
    sudo systemctl enable reflector.timer
    sudo systemctl disable systemd-timesyncd.service
    sudo systemctl enable chronyd.service
    sudo systemctl enable tuned.service
    sudo systemctl enable earlyoom.service
    # sudo systemctl enable fwupd.service
    # not installing cups since I don't have a printer
    # sudo systemctl enable cups.socket

    echo "All needed services enabled"
  fi
  cd ~/repos/dot-files-public

  echo "To install overGrive (Google Drive client) go to https://www.overgrive.com/"
  read -n 1 -p "Press any key once that's complete"

  echo -e "\n Adding Flathub remote to Flatpak \n"
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  echo "Flathub remote added to Flatpak"
  FLATPAKS_TO_INSTALL=(us.zoom.Zoom com.slack.Slack com.discordapp.Discord org.keepassxc.KeePassXC org.prismlauncher.PrismLauncher com.github.tchx84.Flatseal dev.ftb.ftb-app io.github.mpc_qt.mpc-qt md.obsidian.Obsidian)

  echo "Installing all specified flatpaks"
  for FLATPAK in "${FLATPAKS_TO_INSTALL[@]}"
  do 
    echo "Installing ${FLATPAK} flatpak"  
    flatpak install -y --noninteractive flathub ${FLATPAK}
    echo "${FLATPAK} installed"  
  done
  echo "All specified flatpaks installed"
  echo "Updating firmware for available devices"
  sudo fwupdmgr get-devices -y
  sudo fwupdmgr refresh --force -y
  sudo fwupdmgr get-updates -y
  sudo fwupdmgr update -y
  echo "Firmware update for available devices complete"
else
  # assume is ubuntu WSL
  sudo apt-get update
  echo "Upgrading existing packages"
  sudo apt-get upgrade -y

  echo "Installing specified native packages"
  for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
  do 
    echo "Installing ${PACKAGE}"  
    sudo apt-get install -y ${PACKAGE}
    echo "${PACKAGE} installed"  
  done

  echo "All specified native packages installed"
fi
echo "Installing zoxide"
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
echo "zoxide installed"
echo "Installing oh-my-zsh and removing .zshrc from home directory"
# set env vars to prompt to set default shell to zsh and prevent ohmyzsh installer from touching .zshrc
export CHSH=yes
export RUNZSH=no
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --keep-zshrc
echo "oh-my-zsh installed"
rm ~/.zshrc

# if apt is on system
if [[ $DISTRO = "ubuntu_wsl" || $DISTRO = "ubuntu" || $DISTRO = "debian" ]]
then
  ln -s ~/repos/dot-files-public/.dotfiles/apt.zshrc ~/.zshrc
  echo "symlink to .zshrc created"
elif [[ $DISTRO = "fedora" ]]
then
  ln -s ~/repos/dot-files-public/.dotfiles/dnf.zshrc ~/.zshrc
  echo "symlink to .zshrc created"
elif [[ $DISTRO = "arch" ]]
then
  ln -s ~/repos/dot-files-public/.dotfiles/pacman.zshrc ~/.zshrc
  echo "symlink to .zshrc created"
else 
  echo "NOT ON UBUNTU, FEDORA, OR ARCH BASED SYSTEM, NOT SYMLINKING ZSHRC"
fi

# install nvm without touching .zshrc
echo "Installing nvm"
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
echo "nvm installed"
# install latest node LTS version
echo "Installing latest node.js LTS version"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
nvm install --lts
echo "Node.js LTS installed"
echo "installing cheat"
cd /tmp \
  && wget https://github.com/cheat/cheat/releases/download/4.4.0/cheat-linux-amd64.gz \
  && gunzip cheat-linux-amd64.gz \
  && chmod +x cheat-linux-amd64 \
  && sudo mv cheat-linux-amd64 /usr/local/bin/cheat
echo "cheat installed"
cd ~/repos/dot-files-public
# create symlink to .gitconfig
echo "creating symlink to configs"
ln -s ~/repos/dot-files-public/.dotfiles/.gitconfig ~/.gitconfig
if [[ ! $DISTRO = "ubuntu_wsl" ]]
then
  ln -s ~/repos/dot-files-public/.config/redshift ~/.config/redshift
  ln -s ~/repos/dot-files-public/.config/konsolerc ~/.config/konsolerc
  mkdir -p ~/.local/share/konsole
  ln -s ~/repos/dot-files-public/.config/konsole/Default.profile ~/.local/share/konsole/Default.profile
  # ln -s ~/repos/dot-files-public/.config/terminator ~/.config/terminator
fi

echo "symlinks created"
# echo "Restoring Cinnamon config(s)"
# cd ./cinnamon_config
# dconf load /org/cinnamon/ < dconf-settings-mint
# echo "Cinnamon config(s) restored"

# echo "Make linux use local time"
# timedatectl set-local-rtc 1 --adjust-system-clock
# echo "Linux uses local time, time should be fine on windows and linux now"
# TO UNDO THE ABOVE: timedatectl set-local-rtc 0 --adjust-system-clock
echo "Setup complete, enjoy your system :)"
echo "Make sure to reboot your system!"
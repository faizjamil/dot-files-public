# this file will be used to aid setting up a system
# for now i will simply be making symlinks to the dotfiles in this repo as needed
# the following creates a symlink to my .zshrc file
# the script will assume the directory structure indicated in the command below for all other operations

PACKAGES_TO_INSTALL=(python3-dev python3-pip python3-setuptools zsh wget bat ripgrep ca-certificates)
# installing packages
# TODO: script installation of packages based on package managers, account for yum, rpm, and pacman
# include installation for mkvtoolnix and mediainfo
# include steps to install docker desktop instead of docker CE
# PACKAGES_TO_INSTALL=
# for fedora systems
echo "Upgrading packages..."
sudo apt-get update && sudo apt-get upgrade
for PACKAGE in "${PACKAGES_TO_INSTALL[@]}"
do 
    echo Installing ${PACKAGE}  
    sudo apt-get -y install ${PACKAGE}
done
echo ${PACKAGES_TO_INSTALL} installed
echo "installing cheat"
cd /tmp \
  && wget https://github.com/cheat/cheat/releases/download/4.4.0/cheat-linux-amd64.gz \
  && gunzip cheat-linux-amd64.gz \
  && chmod +x cheat-linux-amd64 \
  && sudo mv cheat-linux-amd64 /usr/local/bin/cheat
echo "cheat installed"
echo "installing tldr"
pip3 install tldr
echo "tldr installed"

echo "bat specifc install steps"
mkdir -p ~/.local/bin
ln -s /usr/bin/batcat ~/.local/bin/bat
echo "symlink for bat created"
echo "Installing oh-my-zsh and removing .zshrc from home directory"
wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
sh install.sh --unattended
rm ~/.zshrc
echo "oh-my-zsh installed"

echo "Installing fnm"
# installs fnm 
curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
echo "fnm installed"
# create symlink to .gitconfig and .zshrc
echo "creating symlinks to dotfiles"

ln -s ~/repos/dot-files/.dotfiles/.zshrc_apt ~/.zshrc
ln -s ~/repos/dot-files/.dotfiles/.gitconfig ~/.gitconfig
source ~/.zshrc
# install latest node LTS version
echo "Installing latest node.js LTS version"
fnm install --lts
echo "Node LTS installed"
echo "Installing deno"
curl -fsSL https://deno.land/install.sh | bash -s -- --yes --no-modify-path
echo "Deno installed"
echo "installing thefuck"
pip3 install thefuck --user
echo "thefuck is installed"


echo "Setup complete, enjoy your WSL2 Ubuntu install :)"
echo "Make sure to reboot your system!"
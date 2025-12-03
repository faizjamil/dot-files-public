#!/bin/zsh
# REQUIRES THE FOLLOWING FILES TO BE IN THE SAME DIRECTORY
# .zshrc
# gen_ssh_key
# Brewfile

# modified from https://github.com/newsdaycom/dev/blob/master/osx_setup/dev_setup

## end setup on fail
#set -e

echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# we don't need this cause our existing .zshrc has the path already
# if [[ "$(uname -m)" == "arm64" ]]; then
#     echo "Arm64 detected, adding homebrew to path"
#     echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
#     eval "$(/opt/homebrew/bin/brew shellenv)"
# fi

# clear
#source ~/.zshrc
echo "Installing brew packages"
cd /opt/homebrew/bin/
brew bundle install --force


brew doctor
cd ~/repos/dot-files-public
echo "Installing Oh My ZSH"
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc

# mv ~/.zshrc-newsday ~/.zshrc
echo "Installing nvm"
# install nvm without touching .zshrc
PROFILE=/dev/null bash -c 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash'
echo "nvm installed"
echo "Installing deno"
curl -fsSL https://deno.land/install.sh | bash -s -- --yes --no-modify-path
echo "Deno installed"

rm ~/.zshrc
echo "COPY OVER .zshrc FILE FROM OTHER COMPUTER"
read -n 1 -p "Press any key once that's complete"
source ~/.zshrc

echo "Installing latest node.js LTS version"
echo "yarn\npnpm" >> ~/.nvm/default-packages
nvm install --lts
echo "Node.js LTS is installed"

echo "config npm to silence npm updates"
echo "update-notifier=false" >> ~/.npmrc
echo "npm configured"
echo "Installation complete!"
echo "Enabling show hidden files in Finder"
defaults write com.apple.finder AppleShowAllFiles -boolean true; killall Finder;
echo "Hidden files now shown in Finder"
echo "Generating SSH key, add this to github account then run repo setup script"
bash gen_ssh_key.sh
echo "Please reboot your system and add your SSH key to Github before running the newsday-setup-repos script"

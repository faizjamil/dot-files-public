#!/bin/zsh
# REQUIRES THE FOLLOWING FILES TO BE IN THE SAME DIRECTORY
# .zshrc
# github-keygen
# Brewfile

# modified from https://github.com/newsdaycom/dev/blob/master/osx_setup/dev_setup

## end setup on fail
#set -e

echo "Installing Homebrew"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
if [[ "$(uname -m)" == "arm64" ]]; then
    echo "Arm64 detected, adding homebrew to path"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

clear
#source ~/.zshrc
echo "Installing brew packages"
/opt/homebrew/bin/brew bundle install --force


/opt/homebrew/bin/brew doctor

echo "Installing Oh My ZSH"
zsh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
#rm ~/.zshrc

#echo "COPY OVER .zshrc FILE FROM OTHER COMPUTER"

#read -n 1 -p "Press any key once that's complete"
# mv ~/.zshrc-newsday ~/.zshrc

echo "Installing deno"
curl -fsSL https://deno.land/install.sh | bash -s -- --yes --no-modify-path
echo "Deno installed"
source ~/.zshrc
echo "Installing latest node.js LTS version"
fnm install --lts
echo "Node.js is installed"

echo "Installation complete!"
echo "Enabling show hidden files in Finder"
defaults write com.apple.finder AppleShowAllFiles -boolean true; killall Finder;
echo "Hidden files now shown in Finder"
echo "Generating SSH key, add this to github account then run repo setup script"
bash github-keygen
echo "Please reboot your system and add your SSH key to Github before running the newsday-setup-repos script"

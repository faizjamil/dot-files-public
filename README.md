# dot-files

Contains dotfiles to help me setup systems faster in the future

## Note regarding perms with `~/.ssh` directory

[The ~/.ssh directory and authorized_keys file must have specific restricted permissions (700 for ~/.ssh and 600 for authorized_keys). If they don’t, you won’t be able to log in.](https://docs.digitalocean.com/products/droplets/how-to/add-ssh-keys/to-existing-droplet/#manually)

use the below commands

```sh
chmod -R 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

## Instructions

1. First make sure you have `git` and `curl` installed, if not then install using your available package manager

Example using apt:

```sh
sudo apt update && sudo apt install git curl
```

Example using dnf:

```sh
sudo dnf install git curl
```

2. Clone the repo such that the directory you are executing the bootstrap script from is ~/repos/dot-files. You can use the command below

```sh
git clone https://github.com/faizjamil/dot-files.git ~/repos/dot-files
```

3. Execute the script

```sh
bash bootstrap.sh
```

4. Set default shell to zsh

```sh
chsh -s $(which zsh)
```

From the [`zsh` repo](https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH)
> Note that this will not work if Zsh is not in your authorized shells list (/etc/shells) or if you don't have permission to use chsh. If that's the case you'll need to use a different procedure.

5. Run the following command in `zsh` for some fun.

```sh
autoload -Uz tetriscurses; tetriscurses
```

## TODO

* ~~Automate install of Slack, Zoom, Mullvad VPN, ATLauncher~~ Done, ATLauncher instead of GDLauncher

* Check the host OS and see what package manager it uses and use that package manager without user intervention

* ~~Setup Cinnamon DE with user-defined settings~~ Done last time I checked.

* Add more dot files to better automate deployment of systems
* Test if the following is true:

"Two things that usually catches people off-guard that you should know about fedora:

1. Remember to delete the two preinstalled flatpak remotes which are useless and problematic, they stall your flatpak operations even if you have a perfect internet connection.

```sh
flatpak remote-delete fedora
flatpak remote-delete fedora-testing 
```

2. Do not use chromium and audacity shipped in fedora repo, install chromium-freeworld from rpmfusion and use audacity from flathub instead. Both have been deliberately sabotaged to remove patented codecs so they just don't work right with no warnings."

Also this:
"This is the package to uninstall if you get a preloaded "fedora user agent" plugin installed in your chromium without your permission: fedora-user-agent-chrome. If it was installed without your permission, remember to report this extension as malicious on the chrome store as well."

* Figure out if it is possible to automate rclone setup for Google Drive syncing

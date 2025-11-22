#!/bin/bash
# generate ssh key for github usage
mkdir -p ~/.ssh
#some docs for below are from: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
echo "Creating SSH key..."
ssh-keygen -t ed25519 -C "faizan.jamilwork@gmail.com"
mv ~/.ssh/id_ed25519 ~/.ssh/github_id_ed25519
mv ~/.ssh/id_ed25519.pub ~/.ssh/github_id_ed25519.pub
echo "SSH key created:"
# add to ssh agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_id_ed25519
touch ~/.ssh/authorized_keys
# copy ssh config from this repo to .ssh/config
cp ./ssh_config ~/.ssh/config
# from: https://superuser.com/a/215506
cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub
echo ".ssh directory and file perms set"


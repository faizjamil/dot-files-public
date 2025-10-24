mkdir ~/.ssh
#some docs for below are from: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
ssh-keygen -t ed25519 -C "faizan.jamilwork@gmail.com"

# add to ssh agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/github_id_ed25519
touch ~/.ssh/authorized_keys
# copy ssh config from this repo to .ssh/config
cp ./ssh_config ~/.ssh/config
# from: https://superuser.com/a/215506
cd ~ && chmod 600 ~/.ssh/* && chmod 700 ~/.ssh && chmod 644 ~/.ssh/*.pub
echo ".ssh directory and file perms set"


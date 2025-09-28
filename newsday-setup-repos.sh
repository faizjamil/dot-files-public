#!/bin/bash

echo "downloading repos and creating a symlink"
mkdir -p ~/repos/newsday
cd ~/repos/newsday
git clone git@github.com:newsdaycom/virtual_machines.git
git clone git@github.com:newsdaycom/devsign.git
git clone git@github.com:newsdaycom/ace.git
git clone git@github.com:newsdaycom/microservices.git

ln -s "~/repos/newsday/virtual_machines ~/virtual_machines"

echo "Repos cloned and symlink created"
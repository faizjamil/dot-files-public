#!/usr/bin/env bash

# copy Windows fonts to Linux
sudo mkdir -p /usr/local/share/fonts/WindowsFonts
# unzip fonts to folder
sudo unzip ms_fonts.zip -d /usr/local/share/fonts/WindowsFonts
# set perms
sudo chmod -R 644 /usr/local/share/fonts/WindowsFonts/*
# reset font cache
sudo fc-cache --force
sudo fc-cache-32 --force
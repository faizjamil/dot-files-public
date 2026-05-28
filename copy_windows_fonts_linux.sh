#!/bin/bash
# copy Windows fonts to Linux
mkdir -p /usr/local/share/fonts/WindowsFonts
# unzip fonts to folder
unzip ms_fonts.zip -d /usr/local/share/fonts/WindowsFonts
# set perms
chmod -R 644 /usr/local/share/fonts/WindowsFonts/*
# reset font cache
fc-cache --force
fc-cache-32 --force
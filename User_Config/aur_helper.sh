#!/bin/bash                                                    

sudo pacman -Sy --needed --noconfirm base-devel git

mkdir -p ~/AUR
cd ~/AUR

git clone https://aur.archlinux.org/yay.git 
cd yay

makepkg -si --noconfirm

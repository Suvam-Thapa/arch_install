#!/bin/bash                                                    

cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R $(whoami) ./yay
cd yay
makepkg -si --noconfirm
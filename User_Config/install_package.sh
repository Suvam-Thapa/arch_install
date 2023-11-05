#!/bin/bash

# I will make another script for installing wayland with sway, hypr and more 
echo " Note : The application that will be downloaded are not a Git version, but a stable one."

D_server () {
while true; do
read -p "

Please choose a display server to install : 
options only includes (for now)

1. Xorg

Note : If You don't want to install enter Nn(no)

choose (1 || Nn): " _install_d_server

  case $_install_d_server in
    [1]* )
      sudo pacman -S xorg --ignore xf86-video-vesa
    break;;
    [Nn]* )
    break;;
      * ) 
    echo "Invalid choice. Please enter a valid option ! ";;
	esac
done
}

login_manager () {
while true; do
read -p "

Please select a login manager that suits your preferences for installation.

options includes :
1. SDDM                  2. Light DM                3. GDM

Note : If You don't want to install enter Nn(no)

choose (1 || 2 || 3 || Nn): " login_manager_choice

  case $login_manager_choice in
    [1]* )
      sudo pacman -S --noconfirm sddm
    break;;
    [2]* ) 
      sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
    break;;
	  [3]* )
      sudo pacman -S --noconfirm gdm
	  break;;
    [Nn]* )
    break;;
      * ) 
      echo "Invalid choice. Please enter a valid option ! ";;
	esac
done
}

window_manager () {
while true; do 
read -p "

Please select a window manager for installation.

choices includes :
1. BSPWM                  2. awesome                3. qtile          4. I3

Note : If You don't want to install any enter Nn(no)

choose (1 || 2 || 3 || Nn): " wm_choice

  case $wm_choice in
    [1]* )
      # Install bspwm
      sudo pacman -S --noconfirm bspwm sxhkd
      mkdir ~/.config/bspwm
      sudo cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm
      mkdir ~/.config/sxhkd
      sudo cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd
    break;;
    [2]* ) 
      # Install awesome
      yay -S awesome-git
      mkdir ~/.config/awesome/
      sudo cp /etc/xdg/awesome/rc.lua ~/.config/awesome/
    break;;
	  [3]* )
      # Install qtile
      sudo pacman -S --noconfirm qtile
      mkdir ~/.config/qtile/
      sudo cp /usr/share/doc/qtile/default_config.py ~/.config/qtile/config.py
    break;;
    [Nn]* )
    break;;
      * ) 
      echo "Invalid choice. Please enter a valid option ! ";;
  esac
done
}

terminal () {
while true; do
read -p " 

Please choose a terminal to insall 

options includes :

1. Alacritty                2. Xterm                    3. Kitty

choose (1 || 2 || 3 || Nn): " term_choice

  case $term_choice in
    [1]* ) 
      # Install alacritty
      sudo pacman -S --noconfirm alacritty
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/alacritty/' ~/.config/sxhkd/sxhkdrc
      elif [[ "$wm_choice" = 2 ]]
      then
      sed -i 's/^terminal = "xterm"/terminal = "alacritty"/' ~/.config/awesome/rc.lua
      fi
    break;;
    [2]* ) 
      # Install xterm
      sudo pacman -S --noconfirm xterm
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/xterm/' ~/.config/sxhkd/sxhkdrc
      fi
    break;;
    [3]* ) 
      # Install kitty
      sudo pacman -S --noconfirm kitty
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/kitty/' ~/.config/sxhkd/sxhkdrc
      fi
    break;;
    [Nn]* )
    break;;
      * ) 
      echo "Invalid choice. Please enter a valid option ! ";;
  esac
done 
}

D_server
clear
window_manager
clear
login_manager
clear
terminal
clear

# Prompt user for additional software installation (optional)
read -p "Do you want to install additional software? (y/n): " additional_software_choice

if [ "$additional_software_choice" == "y" ]; then
  # Prompt for additional software packages
  read -p "Provide space-separated names of other applications to install: " package_list
  yay -S $package_list
fi
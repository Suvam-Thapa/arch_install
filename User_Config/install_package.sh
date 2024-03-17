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
1. SDDM                  2. Light DM               

Note : If You don't want to install enter Nn(no)

choose (1 || 2 || Nn): " login_manager_choice

  case $login_manager_choice in
    [1]* )
      sudo pacman -S --noconfirm sddm
    break;;
    [2]* ) 
      sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
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
1. BSPWM                  2. awesome                3. qtile

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
      yay -S --noconfirm awesome-git
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

F_manager () {
while true; do
read -p "

Please select a file manager that suits your preferences for installation.

options includes :
1. Thunar                  2. PCManFM              

Note : If You don't want to install enter Nn(no)

choose (1 || 2 || Nn): " file_manager_choice

  case $file_manager_choice in
    [1]* )
      sudo pacman -S --noconfirm thunar tumbler thunar-volman
    break;;
    [2]* ) 
      sudo pacman -S --noconfirm pcmanfm
    break;;
    [Nn]* )
    break;;
      * ) 
      echo "Invalid choice. Please enter a valid option ! ";;
	esac
done
}

O_drivers () {
  yay -S --noconfirm mkinitcpio-firmware --ignore linux
}

D_server

clear
window_manager

clear
login_manager

clear
terminal

clear
F_manager

clear
O_drivers
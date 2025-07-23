#!/bin/bash

D_server () {
  while true; do
    read -p "

Please choose a display server to install:
Options only include (for now):

1. Xorg

Note: If you don't want to install, enter N/n (no)

Choose (1 / N/n) [Default: Xorg: 1]: " _install_d_server

    _install_d_server=${_install_d_server:-1}

    case $_install_d_server in
      1)
        echo "Installing Xorg (xorg-server + xorg-xinit)..."
        sudo pacman -S --needed --noconfirm xorg-server xorg-xinit xorg-apps
        break
        ;;
      [Nn]*)
        echo "Skipping Xorg installation."
        break
        ;;
      *)
        echo "Invalid choice. Please enter either '1' or 'N/n'."
        ;;
    esac
  done
}

login_manager () {
  while true; do
    read -p "

Please select a login manager that suits your preferences for installation.

Options include:
1. SDDM                  2. LightDM               

Note: If you don't want to install, enter N/n (no)

Choose (1 / 2 / N/n) [Default: SDDM: 1]: " login_manager_choice

    login_manager_choice=${login_manager_choice:-1}

    case $login_manager_choice in
      1)
        echo "Installing SDDM..."
        sudo pacman -S --needed --noconfirm sddm
        sudo systemctl enable sddm
        break
        ;;
      2)
        echo "Installing LightDM with GTK greeter..."
        sudo pacman -S --needed --noconfirm lightdm lightdm-gtk-greeter
        sudo systemctl enable lightdm
        break
        ;;
      [Nn]*)
        echo "Skipping login manager installation."
        break
        ;;
      *)
        echo "Invalid choice. Please enter '1', '2', or 'N/n'."
        ;;
    esac
  done
}

window_manager () {
while true; do 
read -p "

Please select a window manager for installation.

choices includes :
1. DWM(alacritty + rofi + sddm)                  2. awesome                3. qtile                4. BSPWM

Note : If You don't want to install any enter Nn(no)

choose (1 || 2 || 3 || 4 || Nn): " wm_choice

  case $wm_choice in
    [1]* )
      # Install DWM
    dwmdir="$HOME/.config/dwm"

    if [ ! -d "$dwmdir" ]; then
        mkdir -p ~/.config
        cd ~/.config || exit 1
        git clone https://git.suckless.org/dwm 
        cd ~/.config/dwm/
    else
        echo "Using existing DWM in ~/.config/dwm"
        cd "$dwmdir" || { echo "Failed to enter dwmdir"; exit 1; }
    fi

    # --- PATCHES START HERE ---
    if grep -q "\"st\",.*" ~/.config/dwm/config.def.h; then
        sed -i 's/"st"/"alacritty"/' ~/.config/dwm/config.def.h
    else
        echo "⚠️ Could not find \"st\" in config.def.h — maybe already patched?"
    fi

    cp config.def.h config.h
    sudo pacman -S --noconfirm dmenu
    sudo make clean install
    sudo mkdir /usr/share/xsessions
    sudo tee /usr/share/xsessions/dwm.desktop <<EOF
[Desktop Entry]
Name=Dwm
Comment=Dynamic Window Manager
Exec=/usr/local/bin/dwm
Type=Application
Keywords=windowmanager;
EOF

    break;;
    [2]* ) 
      # Install awesome
      yay -S --noconfirm awesome-git
      mkdir ~/.config/awesome/
      sudo cp /etc/xdg/awesome/rc.lua ~/.config/awesome/
    break;;
	  [3]* )
      # Install qtile
      sudo pacman -S --needed --noconfirm qtile
      mkdir ~/.config/qtile/
      sudo cp /usr/share/doc/qtile/default_config.py ~/.config/qtile/config.py
    break;;
    [4]* )
      # Install bspwm
      sudo pacman -S --needed --noconfirm bspwm sxhkd
      mkdir ~/.config/bspwm
      sudo cp /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm
      mkdir ~/.config/sxhkd
      sudo cp /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd
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

choose (1 || 2 || 3 || Nn) [Defaults: Alacritty: 1]: " term_choice

  term_choice=${term_choice:-1}

  case $term_choice in
    [1]* ) 
      # Install alacritty
      sudo pacman -S --needed --noconfirm alacritty
      if [[ "$wm_choice" = 4 ]]
      then 
      sed -i 's/urxvt/alacritty/' ~/.config/sxhkd/sxhkdrc
      elif [[ "$wm_choice" = 2 ]]
      then
      sed -i 's/^terminal = "xterm"/terminal = "alacritty"/' ~/.config/awesome/rc.lua
      fi
    break;;
    [2]* ) 
      # Install xterm
      sudo pacman -S --needed --noconfirm xterm
      if [[ "$wm_choice" = 4 ]]
      then 
      sed -i 's/urxvt/xterm/' ~/.config/sxhkd/sxhkdrc
      fi
    break;;
    [3]* ) 
      # Install kitty
      sudo pacman -S --needed --noconfirm kitty
      if [[ "$wm_choice" = 4 ]]
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

choose (1 || 2 || Nn) [Default : Thunar: 1]: " file_manager_choice

  file_manager_choice=${file_manager_choice:-1}

  case $file_manager_choice in
    [1]* )
      sudo pacman -S --needed --noconfirm thunar tumbler thunar-volman
    break;;
    [2]* ) 
      sudo pacman -S --needed --noconfirm pcmanfm
    break;;
    [Nn]* )
    break;;
      * ) 
      echo "Invalid choice. Please enter a valid option ! ";;
	esac
done
}

Def_applications () {
while true; do
read -p "
            
This script will install [brave,code,hotspot_app]. Do you want to continue? (y/n):
Note : If You don't want to install enter Nn(no)
[Default : Yes]: " deff_app_choice

  deff_app_choice=${deff_app_choice:-Y}

  case $deff_app_choice in
    [Yy]* )
      yay -S --needed --noconfirm linux-wifi-hotspot brave-bin code dnsmasq polkit-gnome
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
F_manager

clear
Def_applications

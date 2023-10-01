#!/bin/bash

echo -ne "

╭━━╮  ╭━┳╮       ╭╮            ╭╮       ╭━╮
╰┃┃╋━┳┫━┫╰┳━╮╭╮╭╮┣╋━┳┳━╮╭━┳━╮╭━┫┣┳━╮╭━┳━┫━┫
╭┃┃┫┃┃┣━┃╭┫╋╰┫╰┫╰┫┃┃┃┃╋┃┃╋┃╋╰┫━┫━┫╋╰┫╋┃┻╋━┃
╰━━┻┻━┻━┻━┻━━┻━┻━┻┻┻━╋╮┃┃╭┻━━┻━┻┻┻━━╋╮┣━┻━╯
                      ╰━╯╰╯         ╰━╯

"
Xorg () {
while true; do
read -p "Do you want to install Xorg display_server :(Yy/Nn) : " _choice
    case $_choice in
        [Yy]* )
            sudo pacman -S --noconfirm xorg --ignore xf86-video-vesa
        break;;
        [Nn]* ) 
        break;;
        * ) echo "Please answer yes or no.";;
    esac
done
}

lm_install () {
while true; do
read -p "
Do you want to install login mananger for your window mananger (wm)


choices includes :
1. SDDM                  2. Light DM                3. GDM

Note : If You don't want to install lm enter Nn(no)


choose (1/2/3/Nn): " login_manager_choice

  case $login_manager_choice in
    1)
      # Install SDDM
      sudo pacman -S --noconfirm sddm
      ;;
    2)
      # Install LightDM
      sudo pacman -S --noconfirm lightdm lightdm-gtk-greeter
      ;;
    3)
      # Install GDM
      sudo pacman -S --noconfirm gdm
      ;;
    [Nn]* ) 
      break;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
  esac
done
}

WM_install () {
while true; do
read -p "
Do you want to install Window Mananger


choices includes :
1. BSPWM                  2. awesome                3. qtile 

Note : If You don't want to install wm enter Nn(no)


choose (1/2/3/Nn): " wm_choice

  case $wm_choice in
    1)
      # Install bspwm
      sudo pacman -S --noconfirm bspwm sxhkd
      mkdir .config/bspwm
      sudo cp /usr/share/doc/bspwm/examples/bspwmrc .config/bspwm
      mkdir .config/sxhkd
      sudo cp /usr/share/doc/bspwm/examples/sxhkdrc .config/sxhkd
      ;;
    2)
      # Install awesome
      yay -S awesome-git
      mkdir .config/awesome/
      sudo cp /etc/xdg/awesome/rc.lua .config/awesome/
      ;;
    3)
      # Install qtile
      sudo pacman -S --noconfirm qtile
      mkdir .config/qtile/
      sudo cp /usr/share/doc/qtile/default_config.py .config/qtile/config.py
      ;;
    [Nn]* ) 
      break;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
  esac
done
  if [ "$wm_choice" = 1 ] || [ "$wm_choice" = 2 ] || [ "$wm_choice" = 3 ]
  then
    lm_install
  elif [[ "$wm_choice" = "Nn" ]]
  then
    echo "wm not installed !"
  fi
while true; do 
  read -p " 
Please choose a terminal to insall 


options includes :

1. Alacritty                2. Xterm                    3. Kitty

Don't want to you know what to do !

choose (1/2/3/Nn): " term_choice

  case $term_choice in
    1)
      # Install alacritty
      sudo pacman -S --noconfirm alacritty
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/alacritty/' .config/sxhkd/sxhkdrc
      elif [[ "$wm_choice" = 2 ]]
      then
      sed -i 's/^terminal = "xterm"/terminal = "alacritty"/' .config/awesome/rc.lua
      fi
      ;;
    2)
      # Install xterm
      sudo pacman -S --noconfirm xterm
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/xterm/' .config/sxhkd/sxhkdrc
      fi
      ;;
    3)
      # Install kitty
      sudo pacman -S --noconfirm kitty
      if [[ "$wm_choice" = 1 ]]
      then 
      sed -i 's/urxvt/kitty/' .config/sxhkd/sxhkdrc
      fi
      ;;
    [Nn]* ) 
      break;;
    *)
      echo "Invalid choice. Please enter a valid option."
      ;;
  esac
done
}

Xorg
WM_install

# Prompt user for additional software installation (optional)
read -p "Do you want to install additional software? (y/n): " additional_software_choice

if [ "$additional_software_choice" == "y" ]; then
  # Prompt for additional software packages
  read -p "Provide space-separated names of other applications to install: " package_list
  yay -S $package_list
fi


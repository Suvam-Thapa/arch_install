#!/bin/bash

echo -ne "

╭━━╮ ╭╮         ╭╮  ╭━┳╮          ╭╮╭╮
╰╮╮┣┳╋╋━┳━┳━┳┳╮ ┣╋━┳┫━┫╰┳━╮╭╮╭╮╭━╮┃╰╋╋━┳━┳╮
╭┻╯┃╭┫┣╮┃╭┫┻┫╭╯ ┃┃┃┃┣━┃╭┫╋╰┫╰┫╰┫╋╰┫╭┫┃╋┃┃┃┃
╰━━┻╯╰╯╰━╯╰━┻╯  ╰┻┻━┻━┻━┻━━┻━┻━┻━━┻━┻┻━┻┻━╯

"

clear

Driver () {
while true; do
read -p "

Driver options for installation :

    1.nvidia-390xx                 2.nvidia-340xx                3.nvidia-470xx
    
Provide a num (1,2,3) --> [Default: 390xx: 1] " input_d
    input_d=${input_d:-1}
    case $input_d in
        [1]* )
            yay -S --needed --noconfirm nvidia-390xx-dkms nvidia-390xx-utils nvidia-390xx-settings 
            yay -S --needed --noconfirm opencl-nvidia-390xx 
        break;;
        [2]* ) 
            yay -S --needed --noconfirm nvidia-340xx-dkms nvidia-340xx-utils nvidia-340xx-settings 
            yay -S --needed --noconfirm opencl-nvidia-340xx 
        break;;
	    [3]* )
	        yay -S --needed --noconfirm nvidia-470xx-dkms nvidia-470xx-utils nvidia-470xx-settings 
            yay -S --needed --noconfirm opencl-nvidia-470xx 
	    break;;
        * ) echo "Please provide a num from above options";;
	esac
done
}

Kernel () {
read -p "

Choose Kernal you're using (options) :

    1.linux-zen              2.linux-hardened             3.linux
   
Provide a num (1,2,3) -->[Default: zen: 1] " input_k
    input_k=${input_k:-1}
}

Display_manager () {
read -p "

Choose display manager you're using (options) :

    1. SDDM               2. Light DM                  3. GDM 

Provide a num (1,,2,3) -->[Default: sddm: 1] " input_dm
    input_dm=${input_dm:-1}
}

Kernel
clear
Display_manager
clear
Driver

# Using NVIDIA graphics only  # Arch wiki

# Configuration for xorg 

sudo printf "Section \"OutputClass\"
    Identifier \"intel\"
    MatchDriver \"i915\"
    Driver \"modesetting\"
    Option \"UseEDID\" \"true\"
    Option \"ModeValidation\" \"NoVirtualSizeCheck\"
EndSection

Section \"OutputClass\"
    Identifier \"nvidia\"
    MatchDriver \"nvidia-drm\"
    Driver \"nvidia\"
    Option \"PrimaryGPU\" \"yes\"
    Option \"AllowEmptyInitialConfiguration\" \"true\"
    Option \"AllowExternalGpus\" \"true\"
    ModulePath \"/usr/lib/nvidia/xorg\"
    ModulePath \"/usr/lib/xorg/modules\"
EndSection
" | cat >> 10-nvidia-drm-outputclass.conf

sudo mv 10-nvidia-drm-outputclass.conf /etc/X11/xorg.conf.d/
sudo chown -hR root:root /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf

# Setting configuration for display managers

if [[ $input_dm = 1 ]]          # For SDDM
then 
sudo printf "#!/bin/sh
# Xsetup - run as root before the login dialog appears
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
" | cat >> Xsetup
    sudo rm -r /usr/share/sddm/scripts/Xsetup
    sudo mv Xsetup /usr/share/sddm/scripts/
    sudo chmod +x /usr/share/sddm/scripts/Xsetup
    sudo chown -hR root:root /usr/share/sddm/scripts/Xsetup
elif [[ $input_dm = 2 ]]        # For Light DM
then
sudo printf "#!/bin/sh
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
" | cat >> display_setup.sh
    sudo mv display_setup.sh /etc/lightdm/
    sudo chmod +x /etc/lightdm/display_setup.sh
    sudo chown -hR root:root /etc/lightdm/display_setup.sh
    sed -i 's/^#display-setup-script\=/display-setup-script\=\/etc\/lightdm\/display_setup.sh/' /etc/lightdm/lightdm.conf
elif [[ $input_dm = 3 ]]            # For GDM
then 
sudo printf "[Desktop Entry]
Type=Application
Name=Optimus
Exec=sh -c \"xrandr --setprovideroutputsource modesetting NVIDIA-0; xrandr --auto\"
NoDisplay=true
X-GNOME-Autostart-Phase=DisplayServer
" | cat >> optimus.desktop
    sudo cp optimus.desktop optimus1.desktop
    sudo mv optimus.desktop /usr/share/gdm/greeter/autostart/
    sudo chown -hR root:root /usr/share/gdm/greeter/autostart/optimus.desktop
    sudo mv optimus1.desktop optimus.desktop
    sudo mv optimus.desktop /etc/xdg/autostart/
    sudo chown -hR root:root /etc/xdg/autostart/optimus.desktop
    sed -i 's/^#WaylandEnable\=false/WaylandEnable\=false/' /etc/gdm/custom.conf
else 
    echo "Choose a num " 
    exit
fi

# Nvidia_drm modset

sudo printf "options nvidia-drm modeset=1" | cat >> nvidia-drm-nomodeset.conf
sudo mv nvidia-drm-nomodeset.conf /etc/modprobe.d/
sudo chown -hR root:root /etc/modprobe.d/nvidia-drm-nomodeset.conf

# Blacklist nouveau driver

sudo printf "blacklist nouveau" | cat >> blacklist.conf
sudo mv blacklist.conf /etc/modprobe.d/
sudo chown -hR root:root /etc/modprobe.d/blacklist.conf

# xprofile for nvidia and polkit
sudo tee ~/.xprofile <<EOF
if ! pgrep -f nvidia-settings > /dev/null; then
    nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
fi
if ! pgrep -f polkit-gnome-authentication-agent-1 > /dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
EOF
sudo chmod +x ~/.xprofile

sudo systemctl mask dev-tpmrm0.device

# Pacman hook for nvidia (avoid the possibility of forgetting to update initramfs after an NVIDIA driver upgrade) # Arch wiki

sudo mkdir /etc/pacman.d/hooks

sudo printf "[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux

[Action]
Description=Update NVIDIA module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
" | cat >> nvidia.hook

# Hook as per driver installed 

if [[ $input_d = 1 ]]
then
    sed -i 's/^Target=nvidia/Target=nvidia-390xx-dkms/' nvidia.hook
elif [[ $input_d = 2 ]]
then
    sed -i 's/^Target=nvidia/Target=nvidia-340xx-dkms/' nvidia.hook
elif [[ $input_d = 3 ]]
then
    sed -i 's/^Target=nvidia/Target=nvidia-470xx-dkms/' nvidia.hook
fi

# kernal in use .. nvhook

if [[ $input_k = 1 ]]
then
    sed -i 's/linux/linux-zen/g' nvidia.hook
elif [[ $input_k = 2 ]]
then
    sed -i 's/linux/linux-hardened/g' nvidia.hook
fi

sudo mv nvidia.hook /etc/pacman.d/hooks/
sudo chmod +x /etc/pacman.d/hooks/nvidia.hook
sudo chown -hR root:root /etc/pacman.d/hooks/nvidia.hook

# Mkinitcpio generate (Initial ramdisk)

sudo mkinitcpio -P

# Done 

echo -ne "
---* Drivers installed  please reboot  !*---                            
"

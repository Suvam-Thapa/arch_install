#!/bin/bash

Pre_install () { 

yay -S --needed --noconfirm nvidia-390xx-utils nvidia-390xx-settings opencl-nvidia-390xx lib32-nvidia-390xx-utils

}

Gcc_v () {

# Note installing nvidia utils using gcc 13 doesn't works so first install it using new gcc after that compile dkms driver
cd /tmp
curl -O https://archive.archlinux.org/packages/g/gcc/gcc-13.2.1-6-x86_64.pkg.tar.zst
curl -O https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-13.2.1-6-x86_64.pkg.tar.zst
cd
sudo pacman -U /tmp/gcc-13.2.1-6-x86_64.pkg.tar.zst /tmp/gcc-libs-13.2.1-6-x86_64.pkg.tar.zst --noconfirm
export CC=gcc-13

}

Driver () {

yay -S --needed --noconfirm nvidia-390xx-dkms nvidia-390xx-utils nvidia-390xx-settings 
yay -S --needed --noconfirm opencl-nvidia-390xx 

}

Display_manager () {

sudo tee /usr/share/sddm/scripts/Xsetup >/dev/null <<'EOF'
#!/bin/sh
xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --auto
EOF

sudo chmod +x /usr/share/sddm/scripts/Xsetup

}

Nv_xorg () { 

# Configuration for xorg 
sudo tee /etc/X11/xorg.conf.d/10-nvidia-drm-outputclass.conf >/dev/null <<'EOF'
Section "OutputClass"
    Identifier "intel"
    MatchDriver "i915"
    Driver "modesetting"
    Option "UseEDID" "true"
    Option "ModeValidation" "NoVirtualSizeCheck"
EndSection

Section "OutputClass"
    Identifier "nvidia"
    MatchDriver "nvidia-drm"
    Driver "nvidia"
    Option "PrimaryGPU" "yes"
    Option "AllowEmptyInitialConfiguration" "true"
    Option "AllowExternalGpus" "true"
    Option "Coolbits" "28"
    ModulePath "/usr/lib/nvidia/xorg"
    ModulePath "/usr/lib/xorg/modules"
EndSection
EOF

}

Touchpad () {

# Touchpad 
sudo pacman -S xf86-input-libinput --noconfirm --needed

sudo tee /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<'EOF'
Section "InputClass"
Identifier "libinput touchpad catchall"
MatchIsTouchpad "on"
MatchDevicePath "/dev/input/event*"
Driver "libinput"
Option "Tapping" "on"
Option "TappingButtonMap" "lmr"
Option "ClickMethod" "clickfinger"
Option "NaturalScrolling" "true"
EndSection
EOF

}

Nv_drm () {

# Nvidia_drm modset
sudo tee /etc/modprobe.d/nvidia-drm-nomodeset.conf >/dev/null <<'EOF'
options nvidia-drm modeset=1 
EOF

}

Blacklist () {

# Blacklist nouveau driver
sudo tee /etc/modprobe.d/blacklist.conf >/dev/null <<'EOF'
blacklist nouveau
EOF

}

Nv_max () {

sudo tee /etc/modprobe.d/nvidia.conf >/dev/null <<'EOF'
options nvidia NVreg_UsePageAttributeTable=1 NVreg_RegistryDwords="PowerMizerEnable=0x1;PerfLevelSrc=0x2222;PowerMizerDefault=0x1;PowerMizerDefaultAC=0x1"
EOF

}

Xprofile () {

# xprofile for nvidia and polkit
tee ~/.xprofile >/dev/null <<'EOF'
export __GL_YIELD="NOTHING"
export __GL_SYNC_TO_VBLANK=0

if ! pgrep -f nvidia-settings > /dev/null; then
    nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
    nvidia-settings -a "[gpu:0]/GPUGraphicsClockOffset[1]=66"
    nvidia-settings -a "[gpu:0]/GPUMemoryTransferRateOffset[1]=150"
fi
if ! pgrep -f polkit-gnome-authentication-agent-1 > /dev/null; then
    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
fi
EOF

chmod +x ~/.xprofile

}

Cpu_govern () { 

sudo tee /etc/systemd/system/cpu-governor.service >/dev/null <<'EOF'
[Unit]
Description=Set preferred CPU governor at boot
After=multi-user.target

[Service]
Type=oneshot
# ExecStart=/bin/sh -c "echo schedutil | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
ExecStart=/bin/sh -c "echo performance | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable cpu-governor

}

Nv_hook () {

# Pacman hook for nvidia (avoid the possibility of forgetting to update initramfs after an NVIDIA driver upgrade) # Arch wiki
sudo mkdir -p /etc/pacman.d/hooks

sudo tee /etc/pacman.d/hooks/nvidia.hook >/dev/null <<'EOF'
[Trigger]
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
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'
EOF

# Hook for installed driver 
sudo sed -i 's/^Target=nvidia/Target=nvidia-390xx-dkms/' /etc/pacman.d/hooks/nvidia.hook
# kernal in use .. nvhook
sudo sed -i 's/linux/linux-zen/g' /etc/pacman.d/hooks/nvidia.hook

sudo chmod +x /etc/pacman.d/hooks/nvidia.hook

}

Gcc_cv () { 

sudo pacman -S --noconfirm gcc

}

Bash () {

tee ~/.bashrc >/dev/null <<'EOF'
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(zoxide init bash)"

alias ls='ls --color=auto -sah'
alias grep='grep --color=auto'
alias svim='sudo -E nvim' 

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

PS1='[\#]\n[\@] [\d]\n[\u@\h \W]\$ '
EOF

}

Pre_install

clear
Gcc_v

clear
Driver

clear
Nv_xorg

clear
Display_manager

clear
Touchpad

clear
Nv_drm

clear
Blacklist

clear
Nv_max

clear
Xprofile

clear
Cpu_govern

clear
Nv_hook

clear
Gcc_cv

clear
Bash
clear

# Mkinitcpio generate (Initial ramdisk)
sudo mkinitcpio -P

# Done 
echo -ne "
---* Drivers installed  please reboot! *---                            
"


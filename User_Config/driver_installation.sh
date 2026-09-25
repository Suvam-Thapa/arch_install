#!/bin/bash

Pre_install () { 

yay -S --needed --noconfirm nvidia-390xx-utils nvidia-390xx-settings opencl-nvidia-390xx lib32-nvidia-390xx-utils

}

Gcc_v () {

# Note installing nvidia utils using gcc 14 doesn't works so first install it using new gcc after that compile dkms driver
cd /tmp
curl -O https://archive.archlinux.org/packages/g/gcc/gcc-14.2.1+r753+g1cd744a6828f-1-x86_64.pkg.tar.zst
curl -O https://archive.archlinux.org/packages/g/gcc-libs/gcc-libs-14.2.1+r753+g1cd744a6828f-1-x86_64.pkg.tar.zst
cd
sudo pacman -U /tmp/gcc-14.2.1+r753+g1cd744a6828f-1-x86_64.pkg.tar.zst /tmp/gcc-libs-14.2.1+r753+g1cd744a6828f-1-x86_64.pkg.tar.zst --noconfirm --overwrite '*'

export CC=gcc-14

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
sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf >/dev/null <<'EOF'
Section "ServerLayout"
    Identifier "layout"
    Screen 0 "nvidia"
    Inactive "intel"
EndSection

Section "Device"
    Identifier "nvidia"
    Driver "nvidia"
    BusID  "PCI:8:0:0"
    Option "Coolbits" "28"
    Option "PrimaryGPU" "yes"
EndSection

Section "Screen"
    Identifier "nvidia"
    Device "nvidia"
    Option "AllowEmptyInitialConfiguration"
    Option "DPI" "100 x 100"
EndSection

Section "Device"
    Identifier "intel"
    Driver "modesetting"
    BusID  "PCI:0:2:0"
EndSection

Section "Screen"
    Identifier "intel"
    Device "intel"
EndSection

Section "Files"
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
Option "DisableWhileTyping" "0"
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
export __GLX_VENDOR_LIBRARY_NAME=nvidia
export __NV_PRIME_RENDER_OFFLOAD=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1
export __GL_THREADED_OPTIMIZATIONS=1
export __GL_YIELD="NOTHING"
export __GL_SYNC_TO_VBLANK=0
export __GL_SHADER_DISK_CACHE="1"
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP="1"
export __GL_MaxFramesAllowed="1"
export VK_DRIVER_FILES=/usr/share/vulkan/icd.d/intel_hasvk_icd.json
export VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/intel_hasvk_icd.json
export MESA_VK_ANTI_LAG=1

xsetroot -solid "#000000"

# systemctl --user import-environment DISPLAY XAUTHORITY
# systemctl --user restart emacs

if ! pgrep -f nvidia-settings > /dev/null; then
    nvidia-settings -a "[gpu:0]/GpuPowerMizerMode=1"
    nvidia-settings -a "[gpu:0]/GPUGraphicsClockOffset[1]=86"
    nvidia-settings -a "[gpu:0]/GPUMemoryTransferRateOffset[1]=220"
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

Bash () {

tee ~/.bashrc >/dev/null <<'EOF'
#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

eval "$(zoxide init bash)"

alias ls='ls --color=auto -ash'
alias p='sudo pacman'
alias sure='systemctl --user restart emacs'
alias grep='grep --color=auto'
alias svim='sudo -E nvim' 
alias va='source ~/.py_venv/bin/activate'

export LS_COLORS="di=01;38;2;7;102;120:\
ln=01;38;2;66;123;88:\
so=38;2;143;63;113:\
pi=38;2;181;118;20:\
ex=01;38;2;121;116;14:\
bd=38;2;175;58;3;01:\
cd=38;2;175;58;3;01:\
su=38;2;157;0;6;01:\
sg=38;2;157;0;6;01:\
tw=38;2;7;102;120;01:\
ow=38;2;7;102;120;01:\
*.tar=38;2;175;58;3:*.zip=38;2;175;58;3:*.gz=38;2;175;58;3:*.xz=38;2;175;58;3:\
*.jpg=38;2;143;63;113:*.png=38;2;143;63;113:*.gif=38;2;143;63;113:*.mp4=38;2;143;63;113:\
*.md=38;2;181;118;20:*.txt=38;2;181;118;20:*.pdf=38;2;181;118;20:\
*.py=38;2;66;123;88:*.rs=38;2;66;123;88:*.c=38;2;66;123;88"

function yz() {
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
Bash
clear

# Mkinitcpio generate (Initial ramdisk)
sudo mkinitcpio -P

# Done 
echo -ne "
---* Drivers installed  please reboot! ( Re-install gcc using su cp -r /tmp/usr/lib/* /usr/lib/ )*---                            
---* Set Python venv if needed ( python -m venv .py_venv/ )*---
"


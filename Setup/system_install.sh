#!/bin/bash

source $Setup_Dir/exec.sh

sys_uefi () {
fdisk "/dev/$d_name" << EOF
g
n
1
2048
+1G
t
1
n
2

+4G
t
2
19
n
3

+160G
n
4


w
EOF

partprobe
clear

mkfs.fat -F 32 /dev/${d_name}1
mkswap /dev/${d_name}2
mkfs.ext4 /dev/${d_name}3
mkfs.ext4 /dev/${d_name}4

mount /dev/${d_name}3 /mnt

mkdir -p /mnt/boot/efi
mkdir /mnt/home

mount /dev/${d_name}1 /mnt/boot/efi
mount /dev/${d_name}4 /mnt/home
swapon /dev/${d_name}2
}

sys_legacy () {
fdisk "/dev/$d_name" << EOF
o
n
1
2048
+4G
t
19
n
2

+160G
n
3


w
EOF

partprobe
clear

mkswap /dev/${d_name}1
mkfs.ext4 /dev/${d_name}2
mkfs.ext4 /dev/${d_name}3

mount /dev/${d_name}2 /mnt

mkdir /mnt/home

mount /dev/${d_name}3 /mnt/home
swapon /dev/${d_name}1
}

pacman -Sy --noconfirm archlinux-keyring

timedatectl set-ntp true

umount -A --recursive /mnt

if [ -d /sys/firmware/efi ] && dmesg | grep -q "EFI v"; then
    sys_uefi
else
    sys_legacy
fi

pacstrap -K /mnt base base-devel linux-zen linux-firmware linux-zen-headers $_install $_ucode pipewire pipewire-pulse pavucontrol xdg-utils xdg-user-dirs networkmanager gvfs ntfs-3g qt6-base qt5-base gtk4 gtk3 gtk2 grub efibootmgr unzip vim git --noconfirm
clear

genfstab -U /mnt >> /mnt/etc/fstab

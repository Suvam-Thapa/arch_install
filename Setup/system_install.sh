#!/bin/bash

source $Setup_Dir/exec.sh

pacman -Sy --noconfirm archlinux-keyring

timedatectl set-ntp true

umount -A --recursive /mnt

swapoff -a

sys_uefi () {
fdisk "/dev/$d_name" << EOF
g
n
1
2048
+1G
t
uefi
n
2

+4G
t
2
swap
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
p
1
2048
+4G
t
swap
n
p
2

+160G
n
p
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

if [ -d /sys/firmware/efi ] && dmesg | grep -q "EFI v"; then
    sys_uefi
else
    sys_legacy
fi

#mkdir -p /tmp/kernels
#cd /tmp/kernels
#curl -LO https://archive.archlinux.org/packages/l/linux-zen/linux-zen-6.6.zen1-1-x86_64.pkg.tar.zst
#curl -LO https://archive.archlinux.org/packages/l/linux-zen-headers/linux-zen-headers-6.6.zen1-1-x86_64.pkg.tar.zst
#sudo pacman -U linux-zen-6.6.zen1-1-x86_64.pkg.tar.zst linux-zen-headers-6.6.zen1-1-x86_64.pkg.tar.zst
#sudo mkinitcpio -P


pacstrap -K /mnt base base-devel linux-zen linux-firmware linux-zen-headers mesa intel-ucode pipewire pipewire-pulse pavucontrol xdg-utils xdg-user-dirs networkmanager gvfs ntfs-3g grub efibootmgr unzip vim git --noconfirm
clear

genfstab -U /mnt >> /mnt/etc/fstab

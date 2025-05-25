#!/bin/bash

Conf_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source $Conf_Dir/exec.sh

ln -sf /usr/share/zoneinfo/$t_zone /etc/localtime

hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sed -i 's/^#en_US ISO-8859-1/en_US ISO-8859-1/' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "$h_name" >> /etc/hostname

clear

echo "Set root pass :: "
passwd

echo "Set user pass :: "
useradd -mG wheel $u_name 
passwd $u_name

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

sed -i 's/^GRUB_TIMEOUT=5/GRUB_TIMEOUT=0/' /etc/default/grub

if [ -d /sys/firmware/efi ] && dmesg | grep -q "EFI v"; then
grub-install
grub-mkconfig -o /boot/grub/grub.cfg
else
grub-install --target=i386-pc $disk_name
grub-mkconfig -o /boot/grub/grub.cfg
fi

systemctl enable NetworkManager

sed -i 's/^#HookDir/HookDir/' /etc/pacman.conf
sed -i 's/^#Color/Color/' /etc/pacman.conf

exit

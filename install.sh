#!/bin/bash
set -a
Workspace_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
Setup_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/Setup
Sys_conf_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/Configuration
Usr_conf_Dir="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"/User_Config
set +a

sudo chmod +x $Setup_Dir/system_install.sh
sudo chmod +x $Setup_Dir/exec.sh
sudo chmod +x $Sys_conf_Dir/config_install.sh
sudo chmod +x $Sys_conf_Dir/exec.sh
sudo chmod +x $Usr_conf_Dir/aur_helper.sh
sudo chmod +x $Usr_conf_Dir/driver_installation.sh
sudo chmod +x $Usr_conf_Dir/install_package.sh
sudo chmod +x $Usr_conf_Dir/install.sh

echo -ne "

╭━━━╮    ╭╮          ╭╮   ╭╮╭╮
┃╭━╮┃    ┃┃         ╭╯╰╮  ┃┃┃┃
┃┃ ┃┣━┳━━┫╰━╮ ╭┳━╮╭━┻╮╭╋━━┫┃┃┃
┃╰━╯┃╭┫╭━┫╭╮┃ ┣┫╭╮┫━━┫┃┃╭╮┃┃┃┃
┃╭━╮┃┃┃╰━┫┃┃┃ ┃┃┃┃┣━━┃╰┫╭╮┃╰┫╰╮
╰╯ ╰┻╯╰━━┻╯╰╯ ╰┻╯╰┻━━┻━┻╯╰┻━┻━╯

"

$Setup_Dir/system_install.sh

mv $Workspace_Dir/Configuration/ /mnt
mv $Workspace_Dir/User_Config/ /mnt

arch-chroot /mnt ./Configuration/config_install.sh

rm -r /mnt/Configuration

umount -R /mnt
reboot


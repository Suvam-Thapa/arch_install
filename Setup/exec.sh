disk_name ()
{
    read -p "Enter your disk drive name (eg. hda,sda,sdb):: " d_name
}

Microcode_gpu () {
_ucode=""

Intel_output=$(lscpu | grep -E "GenuineIntel")
Amd_output=$(lscpu | grep -E "AuthenticAMD")

if [[ -n "$Intel_output" ]]
then
    _ucode="intel-ucode"
elif [[ -n "$Amd_output" ]]
then
    _ucode="amd-ucode"
fi

_install=""

I_output=$(lspci | grep -E -e "Integrated Graphics Controller" -e "Intel Corporation UHD")
A_output=$(lspci | grep -E "Radeon|AMD")

if [[ -n "$I_output" ]]
then
    _install="xf86-video-intel libva-intel-driver libvdpau-va-gl lib32-vulkan-intel vulkan-intel libva-intel-driver libva-utils mesa lib32-mesa"
elif [[ -n "$A_output" ]]
then
    _install="xf86-video-amdgpu"
fi
}
disk_name
Microcode_gpu
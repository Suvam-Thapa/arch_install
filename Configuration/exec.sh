#!/bin/bash

Time_Zone()
{
    t_zone="$(curl --fail https://ipapi.co/timezone)"
}
User_Name ()
{
    local valid_user_regex='^[a-z_][a-z0-9_-]*$'
    local default="suvam"

    while true; do
        read -rp "Enter your username [default: $default]: " u_name

        u_name="${u_name:-$default}"

        if [[ "$u_name" =~ $valid_user_regex ]]; then
            break
        else
            echo "Invalid username. Usernames must start with a lowercase letter or underscore,"
            echo "and may contain lowercase letters, digits, underscores, or hyphens."
        fi
    done
}
Host_Name ()
{
    local valid_host_regex='^[a-zA-Z0-9\-\.]+$'  
    local default="Arch"

    while true; do
        read -rp "Enter hostname [default: $default]: " h_name

        h_name="${h_name:-$default}"  

        if [[ "$h_name" =~ $valid_host_regex ]]; then
            break
        else
            echo "Invalid hostname. Only letters, numbers, dashes, and dots are allowed."
        fi
    done
}
Disk () {
device=$(awk '$2 == "/" { print $1; exit }' /etc/mtab)
disk_name=$(echo $device | sed 's/[0-9]*$//')
}

User_Name
clear
Host_Name
clear
Time_Zone
clear
Disk
#!/bin/bash

TimeZone()
{
    t_zone="$(curl --fail https://ipapi.co/timezone)"
}
UserName ()
{
    read -p "Please fill in your username ? : " u_name
}
HostName ()
{
    read -p "Please provide a name for the host : " h_name
}
disk () {
device=$(awk '$2 == "/" { print $1; exit }' /etc/mtab)
disk_name=$(echo $device | sed 's/[0-9]*$//')
}

UserName

clear

HostName

clear

TimeZone

clear

disk

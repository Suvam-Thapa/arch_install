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
UserName
clear
HostName
clear
TimeZone
clear
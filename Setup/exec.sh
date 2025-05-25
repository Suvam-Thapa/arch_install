#!/bin/bash

disk_name ()
{
    local valid_disk_regex='^[a-zA-Z0-9]+$'
    local default="sda"

    while true; do
        read -rp "Enter your disk drive name [default: $default]: " d_name

        d_name="${d_name:-$default}"

        if [[ "$d_name" =~ $valid_disk_regex ]]; then
            break
        else
            echo "Invalid disk name: '$d_name'. Only letters and numbers are allowed."
        fi
    done
}
disk_name
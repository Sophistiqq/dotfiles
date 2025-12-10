#!/bin/bash

options="logout\nreboot\nshutdown"

selected=$(echo -e $options | rofi -dmenu -p "Power Menu")

case "$selected" in
    logout)
        i3-msg exit
        ;;
    reboot)
        systemctl reboot
        ;;
    shutdown)
        systemctl poweroff
        ;;
esac

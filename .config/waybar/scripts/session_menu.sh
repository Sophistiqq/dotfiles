#!/bin/bash

choice=$(echo -e "Shutdown\nReboot\nSleep\nLogout" | rofi -dmenu -i -p "Session Menu")

case $choice in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Sleep)
        systemctl suspend
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
esac


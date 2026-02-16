#!/usr/bin/env bash

# Menu d'extinction avec wofi
CHOICE=$(echo -e "Shutdown\nReboot\nLogout" | wofi --dmenu)

case "$CHOICE" in
    Shutdown)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Logout)
        hyprctl dispatch exit
        ;;
esac

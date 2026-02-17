#!/usr/bin/env bash

# Menu d'extinction avec wofi
CHOICE=$(echo -e "Shutdown\nReboot\nLogout" | wofi --dmenu)

case "$CHOICE" in
    Shutdown)
        hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'
        ;;
    Reboot)
        hyprshutdown -t 'Restarting...' --post-cmd 'reboot'
        ;;
    Logout)
        hyprshutdown -t 'Logging out...'
        ;;
esac

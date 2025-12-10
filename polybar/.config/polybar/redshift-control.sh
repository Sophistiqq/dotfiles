#!/bin/sh

case "$1" in
    warm)
        redshift -O 4500K
        ;;
    reset)
        redshift -x
        ;;
    status)
        temp=$(redshift -p 2>/dev/null | grep 'Color temperature' | cut -d: -f2 | tr -d 'K ')
        if [ -z "$temp" ] || [ "$temp" -ge 6500 ]; then
            echo " Off"
        else
            echo " ${temp}K"
        fi
        ;;
    *)
        echo "Usage: $0 {warm|reset|status}"
        exit 1
        ;;
esac

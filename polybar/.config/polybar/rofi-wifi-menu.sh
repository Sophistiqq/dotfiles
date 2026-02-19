#!/usr/bin/env bash

DEVICE=${1:-$(iwctl device list 2>/dev/null | sed 's/\x1b\[[0-9;]*m//g' | awk '/station/{print $1}' | head -1)}
[ -z "$DEVICE" ] && notify-send "WiFi" "No wireless device found" && exit 1

parse_networks() {
    iwctl station "$DEVICE" get-networks 2>/dev/null \
        | sed 's/\x1b\[[0-9;]*m//g' \
        | tail -n +5 \
        | sed 's/^\s*>\s*//' \
        | sed 's/^\s*//' \
        | grep -v '^\s*$' \
        | grep -v '^-' \
        | awk -F'  +' '{print $1}' \
        | sed 's/[[:space:]]*$//'
}

get_current() {
    iwctl station "$DEVICE" show 2>/dev/null \
        | sed 's/\x1b\[[0-9;]*m//g' \
        | grep -i "Connected network" \
        | sed 's/.*Connected network\s*//' \
        | xargs
}

is_secured() {
    local ssid="$1"
    iwctl station "$DEVICE" get-networks 2>/dev/null \
        | sed 's/\x1b\[[0-9;]*m//g' \
        | tail -n +5 \
        | awk -F'  +' '{print $1, $2}' \
        | grep -F "$ssid" \
        | grep -qi "psk"
}

# Scan with notification
notify-send "WiFi" "Scanning..." -t 1500
iwctl station "$DEVICE" scan 2>/dev/null
sleep 2

CURRENT=$(get_current)
NETWORKS=$(parse_networks)

if [ -n "$CURRENT" ]; then
    MENU="Disconnect\n  $CURRENT (connected)\n$(echo "$NETWORKS" | grep -vxF "$CURRENT")"
else
    MENU="Disconnect\n$NETWORKS"
fi

CHOICE=$(echo -e "$MENU" | rofi -dmenu -p "  WiFi" -i)
[ -z "$CHOICE" ] && exit 0

if [ "$CHOICE" = "Disconnect" ]; then
    iwctl station "$DEVICE" disconnect
    notify-send "WiFi" "Disconnected"
    exit 0
fi

SSID=$(echo "$CHOICE" | sed 's/ (connected)$//' | sed 's/^  //' | xargs)
[ "$SSID" = "$CURRENT" ] && notify-send "WiFi" "Already connected to $SSID" && exit 0

notify-send "WiFi" "Connecting to $SSID..."

if is_secured "$SSID"; then
    PASSWORD=$(rofi -dmenu -p "Password for $SSID" -password -lines 0)
    [ -z "$PASSWORD" ] && exit 0
    OUTPUT=$(iwctl --passphrase "$PASSWORD" station "$DEVICE" connect "$SSID" 2>&1)
else
    OUTPUT=$(iwctl station "$DEVICE" connect "$SSID" 2>&1)
fi

sleep 2
NEW=$(get_current)
if [ "$NEW" = "$SSID" ]; then
    notify-send "WiFi" "Connected to $SSID"
else
    notify-send "WiFi" "Failed to connect to $SSID" -u critical
fi

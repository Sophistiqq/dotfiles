#!/bin/bash

sleep 3

wlan=$(ip -o link show | awk -F': ' '{print $2}' | grep '^wlan' | head -n1)

echo $wlan

sudo ip link set dev $wlan down
sudo ip link set dev $wlan address 1a:08:c9:39:ff:47
sudo ip link set dev $wlan up


iwctl station $wlan disconnect
iwctl station $wlan scan
iwctl station $wlan connect 'KuyaEric PisoWiFi'






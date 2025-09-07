#!/bin/bash

sudo ip link set wlan0 down
sudo ip link set wlan0 address 1a:08:c9:39:ff:47
sudo ip link set wlan0 up

#!/bin/bash

if pgrep -x "polybar" > /dev/null
then
    killall -q polybar
else
    ~/.config/polybar/launch.sh &
fi

#!/bin/sh

# Kill any running waybar process
pkill -x waybar

# Wait a moment to ensure the process has been terminated
sleep 0.5

# Restart waybar
waybar &

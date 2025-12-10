#!/bin/bash

PID=$(pgrep -x waybar)

if [ -z "$PID" ]; then
  waybar &
else
  kill "$PID"
fi

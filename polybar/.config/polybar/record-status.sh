#!/bin/bash
PIDFILE="/tmp/screenrecorder.pid"

if [ -f "$PIDFILE" ]; then
    echo "%{F#FF0000}[REC]%{F-}"
else
    echo "[REC]"
fi

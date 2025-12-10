#!/bin/bash


PIDFILE="/tmp/screenrecorder.pid"
# Revise this to not overwrite the file if it already exists
# OUT="$HOME/Videos/rec_$(date +%F_$T).mkv"
# OUT="$HOME/Videos/rec_$(date +%F_%T_%N).mkv"
# OUTPUT an mp4 file
OUT="$HOME/Videos/rec_$(date +%F_%T_%N).mp4"
if [ -f "$PIDFILE" ]; then
  kill "$(cat $PIDFILE)"
  rm "$PIDFILE"
  notify-send "Screen recording stopped"
else
  # output an mp4
  # ffmpeg -video_size 1366x768 -framerate 24 -f x11grab -i :0.0+0,0 "$OUT" &
  ffmpeg -video_size 1366x768 -framerate 24 -f x11grab -i :0.0+0,0 -c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -pix_fmt yuv420p "$OUT" &
  echo $! > "$PIDFILE"
  notify-send "Screen recording started > $OUT"
fi

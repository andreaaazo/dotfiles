#!/bin/bash

killall mpvpaper 2>/dev/null
sleep 0.5

VIDEO_PATH="$HOME/Pictures/Wallpapers/Blue_Queen.mp4"

MONITOR="*"

if [ ! -f "$VIDEO_PATH" ]; then
    echo "ERROR: Video file not found at $VIDEO_PATH"
    exit 1
fi

mpvpaper -o "no-audio --loop-file=inf --hwdec=auto --target-colorspace-hint" "$MONITOR" "$VIDEO_PATH" > /tmp/mpvpaper.log 2>&1

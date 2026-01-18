#!/bin/bash

killall mpvpaper 2>/dev/null

VIDEO_PATH="$HOME/Pictures/Wallpapers/black_hole_purple.mp4"

MONITOR="*"

if [ ! -f "$VIDEO_PATH" ]; then
    echo "ERROR: Video file not found at $VIDEO_PATH"
    exit 1
fi

mpvpaper -o "no-audio --loop-file=inf --hwdec=auto --target-colorspace-hint" "$MONITOR" "$VIDEO_PATH" > /tmp/mpvpaper.log 2>&1

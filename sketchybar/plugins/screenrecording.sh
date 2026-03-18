#!/bin/bash

# Screen recording indicator — matches latiarch custom/screenrecording-indicator
# Shows a red dot when screen recording is active
if pgrep -x "screencaptured" > /dev/null 2>&1 || \
   pgrep -x "QuickTimePlayerX" > /dev/null 2>&1 || \
   osascript -e 'tell application "System Events" to get name of processes whose name contains "ScreenRecordingHelper"' 2>/dev/null | grep -q "ScreenRecordingHelper"; then
  sketchybar --set "$NAME" label="" label.color=0xffa55555 label.drawing=on
else
  sketchybar --set "$NAME" label.drawing=off
fi

#!/bin/bash

# shellcheck source=/dev/null
source "$HOME/.config/sketchybar/colors.sh"

# printf hex bytes — works on bash 3.2 (macOS default)
# U+F293 nf-fa-bluetooth, U+F294 nf-fa-bluetooth-b
ICON_BT=$(printf '\xef\x8a\x93')
ICON_BT_ON=$(printf '\xef\x8a\x94')

case "$SENDER" in
  "mouse.entered")
    sketchybar --set "$NAME" popup.drawing=on
    exit 0
    ;;
  "mouse.exited"|"mouse.exited.global")
    sketchybar --set "$NAME" popup.drawing=off
    exit 0
    ;;
esac

BT_DATA=$(system_profiler SPBluetoothDataType 2>/dev/null)
BT_STATE=$(echo "$BT_DATA" | awk '/State:/ {print $2; exit}')
BT_CONNECTIONS=$(echo "$BT_DATA" | grep -c "Connected: Yes" 2>/dev/null || echo 0)

if [ "$BT_STATE" = "On" ]; then
  if [ "$BT_CONNECTIONS" -gt 0 ]; then
    sketchybar --set "$NAME" icon="$ICON_BT_ON" icon.color=$FG_COLOR
    if [ "$BT_CONNECTIONS" -eq 1 ]; then
      DETAIL="1 connected"
    else
      DETAIL="${BT_CONNECTIONS} connected"
    fi
  else
    sketchybar --set "$NAME" icon="$ICON_BT" icon.color=$FG_COLOR
    DETAIL="No devices"
  fi
else
  sketchybar --set "$NAME" icon="$ICON_BT" icon.color=$FG_DIM
  DETAIL="Off"
fi

sketchybar --set bluetooth.detail label="$DETAIL"

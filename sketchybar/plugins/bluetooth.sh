#!/bin/bash

# printf hex bytes — works on bash 3.2 (macOS default)
# U+F293 nf-fa-bluetooth, U+F294 nf-fa-bluetooth-b
ICON_BT=$(printf '\xef\x8a\x93')
ICON_BT_ON=$(printf '\xef\x8a\x94')

BT_STATE=$(system_profiler SPBluetoothDataType 2>/dev/null | awk '/State:/ {print $2; exit}')
BT_CONNECTIONS=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -c "Connected: Yes" 2>/dev/null || echo 0)

if [ "$BT_STATE" = "On" ]; then
  if [ "$BT_CONNECTIONS" -gt 0 ]; then
    sketchybar --set "$NAME" icon="$ICON_BT_ON" icon.color=0xfff8f8f2
  else
    sketchybar --set "$NAME" icon="$ICON_BT" icon.color=0xfff8f8f2
  fi
else
  sketchybar --set "$NAME" icon="$ICON_BT" icon.color=0xff6272a4
fi

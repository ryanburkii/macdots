#!/bin/bash

# printf hex bytes — works on bash 3.2 (macOS default)
# U+F1EB nf-fa-wifi, U+F071 nf-fa-exclamation-triangle (no signal)
ICON_CONNECTED=$(printf '\xef\x87\xab')
ICON_OFF=$(printf '\xef\x81\xb1')

# ipconfig getsummary is reliable on macOS 26 (networksetup -getairportnetwork is not)
SSID=$(ipconfig getsummary en0 2>/dev/null | grep -v BSSID | grep "SSID :")

if [ -n "$SSID" ]; then
  ICON="$ICON_CONNECTED"
else
  ICON="$ICON_OFF"
fi

sketchybar --set "$NAME" icon="$ICON"

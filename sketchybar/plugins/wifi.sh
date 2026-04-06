#!/bin/bash

# printf hex bytes — works on bash 3.2 (macOS default)
# U+F1EB nf-fa-wifi, U+EF44 ethernet, U+F071 nf-fa-exclamation-triangle (no signal)
ICON_WIFI=$(printf '\xef\x87\xab')
ICON_ETH=$(printf '\xee\xbd\x84')
ICON_OFF=$(printf '\xef\x81\xb1')

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

# ipconfig getsummary is reliable on macOS 26 (networksetup -getairportnetwork is not)
SSID=$(ipconfig getsummary en0 2>/dev/null | grep -v BSSID | awk -F': ' '/SSID :/ {print $2}')

if [ -n "$SSID" ]; then
  ICON="$ICON_WIFI"
  IP=$(ipconfig getifaddr en0 2>/dev/null)
  if [ -n "$IP" ]; then
    DETAIL="${SSID} · ${IP}"
  else
    DETAIL="$SSID"
  fi
else
  # Check for active ethernet (covers built-in, Thunderbolt, and USB adapters)
  ETH_IP=""
  ETH_IFACE=""
  for iface in en1 en2 en3 en4 en5 en6 en7 en8 en9; do
    ETH_IP=$(ipconfig getifaddr "$iface" 2>/dev/null)
    if [ -n "$ETH_IP" ]; then
      ETH_IFACE="$iface"
      break
    fi
  done

  if [ -n "$ETH_IP" ]; then
    ICON="$ICON_ETH"
    DETAIL="Ethernet · ${ETH_IP}"
  else
    ICON="$ICON_OFF"
    DETAIL="No Connection"
  fi
fi

sketchybar --set "$NAME" icon="$ICON"
sketchybar --set wifi.detail label="$DETAIL"

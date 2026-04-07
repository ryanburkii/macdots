#!/bin/bash

STATUS=$(/usr/local/bin/tailscale status --json 2>/dev/null |
  python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('BackendState','Unknown'))" \
    2>/dev/null || echo "Unknown")

if [ "$STATUS" = "Running" ]; then
  # Tailscale is active — show the item
  sketchybar --set tailscale \
    drawing=on \
    icon="󰦝" \
    icon.color=0xff5ba7fa \
    label.drawing=off
else
  # Tailscale is not running — hide the item entirely
  sketchybar --set tailscale drawing=off
fi

#!/bin/bash

# printf hex bytes — works on bash 3.2 (macOS default)
# U+F026 nf-fa-volume-off, U+F027 nf-fa-volume-down, U+F028 nf-fa-volume-up
ICON_MUTED=$(printf '\xef\x80\xa6')
ICON_LOW=$(printf '\xef\x80\xa7')
ICON_HIGH=$(printf '\xef\x80\xa8')

VOLUME=$(osascript -e "output volume of (get volume settings)" 2>/dev/null)
MUTED=$(osascript -e "output muted of (get volume settings)" 2>/dev/null)

if [ "$MUTED" = "true" ] || [ -z "$VOLUME" ]; then
  ICON="$ICON_MUTED"
elif [ "$VOLUME" -ge 50 ]; then
  ICON="$ICON_HIGH"
else
  ICON="$ICON_LOW"
fi

sketchybar --set "$NAME" icon="$ICON"

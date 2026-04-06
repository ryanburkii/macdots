#!/bin/bash

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

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep "AC Power")

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" icon="󰂑"
  sketchybar --set battery.detail label="Unknown"
  exit 0
fi

if [ "$CHARGING" != "" ]; then
  STATUS="Charging"
  if   [ "$PERCENTAGE" -ge 95 ]; then ICON="󰂅"
  elif [ "$PERCENTAGE" -ge 85 ]; then ICON="󰂋"
  elif [ "$PERCENTAGE" -ge 75 ]; then ICON="󰂊"
  elif [ "$PERCENTAGE" -ge 65 ]; then ICON="󰢞"
  elif [ "$PERCENTAGE" -ge 55 ]; then ICON="󰂉"
  elif [ "$PERCENTAGE" -ge 45 ]; then ICON="󰢝"
  elif [ "$PERCENTAGE" -ge 35 ]; then ICON="󰂈"
  elif [ "$PERCENTAGE" -ge 25 ]; then ICON="󰂇"
  elif [ "$PERCENTAGE" -ge 10 ]; then ICON="󰂆"
  else                                 ICON="󰢜"
  fi
  sketchybar --set "$NAME" icon="$ICON" icon.color=0xfff8f8f2
else
  STATUS="On Battery"
  if   [ "$PERCENTAGE" -ge 95 ]; then ICON="󰁹"
  elif [ "$PERCENTAGE" -ge 85 ]; then ICON="󰂂"
  elif [ "$PERCENTAGE" -ge 75 ]; then ICON="󰂁"
  elif [ "$PERCENTAGE" -ge 65 ]; then ICON="󰂀"
  elif [ "$PERCENTAGE" -ge 55 ]; then ICON="󰁿"
  elif [ "$PERCENTAGE" -ge 45 ]; then ICON="󰁾"
  elif [ "$PERCENTAGE" -ge 35 ]; then ICON="󰁽"
  elif [ "$PERCENTAGE" -ge 25 ]; then ICON="󰁼"
  elif [ "$PERCENTAGE" -ge 10 ]; then ICON="󰁻"
  else                                 ICON="󰁺"
  fi

  if [ "$PERCENTAGE" -le 20 ]; then
    sketchybar --set "$NAME" icon="$ICON" icon.color=0xffff5555
  else
    sketchybar --set "$NAME" icon="$ICON" icon.color=0xfff8f8f2
  fi
fi

sketchybar --set battery.detail label="${PERCENTAGE}% · ${STATUS}"

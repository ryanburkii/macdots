#!/bin/bash

PERCENTAGE=$(pmset -g batt | grep -Eo "[0-9]+%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep "AC Power")

if [ -z "$PERCENTAGE" ]; then
  sketchybar --set "$NAME" icon="󰂑"
  exit 0
fi

if [ "$CHARGING" != "" ]; then
  # Charging icons (matches latiarch format-icons.charging)
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
  # Discharging icons (matches latiarch format-icons.default)
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

  # Warning: Dracula red at ≤20% (matches latiarch states.warning: 20)
  if [ "$PERCENTAGE" -le 20 ]; then
    sketchybar --set "$NAME" icon="$ICON" icon.color=0xffff5555
  else
    sketchybar --set "$NAME" icon="$ICON" icon.color=0xfff8f8f2
  fi
fi

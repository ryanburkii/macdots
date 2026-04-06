#!/bin/bash

# shellcheck source=/dev/null
source "$HOME/.config/sketchybar/colors.sh"

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

# Update the clock label
sketchybar --set "$NAME" label="$(date '+%A %H:%M')"

# Build calendar, stripping ANSI escape codes (cal bolds today's date)
CAL=$(cal | sed $'s/\033\[[0-9;]*m//g' | sed 's/[[:space:]]*$//')

i=0
while IFS= read -r line; do
  CAL_LINES[$i]="$line"
  i=$((i+1))
done <<< "$CAL"

# Strip leading spaces from header and let SketchyBar center it
HEADER=$(echo "${CAL_LINES[0]}" | sed 's/^[[:space:]]*//')

sketchybar \
  --set clock.cal_header label="$HEADER" \
  --set clock.cal_days   label="${CAL_LINES[1]:-}"

# Determine which week row contains today
TODAY=$(date '+%e' | tr -d ' ')
FIRST_DOW=$(date -j -f "%Y%m%d" "$(date '+%Y%m')01" "+%w" 2>/dev/null)
TODAY_WEEK=$(( (TODAY + FIRST_DOW + 6) / 7 ))

# Set each week row: hide if empty, highlight if it contains today
for w in 1 2 3 4 5 6; do
  line="${CAL_LINES[$((w+1))]:-}"
  if [ -z "$line" ]; then
    sketchybar --set "clock.cal_w${w}" drawing=off
  else
    if [ "$w" -eq "$TODAY_WEEK" ]; then
      COLOR=$ACCENT
    else
      COLOR=$FG_COLOR
    fi
    sketchybar --set "clock.cal_w${w}" drawing=on label="$line" label.color="$COLOR"
  fi
done

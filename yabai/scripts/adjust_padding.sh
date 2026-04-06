#!/bin/bash

SINGLE_PADDING=600
NORMAL_PADDING=10

# Find the ultrawide dynamically by frame width (>3000px)
ULTRAWIDE_DISPLAY=$(yabai -m query --displays | \
  /usr/bin/python3 -c "
import sys, json
displays = json.load(sys.stdin)
for d in displays:
    if d['frame']['w'] > 3000:
        print(d['index'])
        break
")

# No ultrawide connected — nothing to do
if [ -z "$ULTRAWIDE_DISPLAY" ]; then
  exit 0
fi

# Get focused space info
space_info=$(yabai -m query --spaces --space)
space_index=$(echo "$space_info" | jq '.index')
display_index=$(echo "$space_info" | jq '.display')

# Only apply to the ultrawide
if [ "$display_index" -ne "$ULTRAWIDE_DISPLAY" ]; then
  exit 0
fi


tiled_windows=$(yabai -m query --windows --space "$space_index" | jq '[.[] | select(."is-floating" == false and ."is-visible" == true)]')
window_count=$(echo "$tiled_windows" | jq 'length')

if [ "$window_count" -eq 1 ]; then
  single_app=$(echo "$tiled_windows" | jq -r '.[0].app')
  if [ "$single_app" = "Ghostty" ]; then
    yabai -m config --space "$space_index" left_padding $NORMAL_PADDING
    yabai -m config --space "$space_index" right_padding $NORMAL_PADDING
  else
    yabai -m config --space "$space_index" left_padding $SINGLE_PADDING
    yabai -m config --space "$space_index" right_padding $SINGLE_PADDING
  fi
else
  yabai -m config --space "$space_index" left_padding $NORMAL_PADDING
  yabai -m config --space "$space_index" right_padding $NORMAL_PADDING
fi

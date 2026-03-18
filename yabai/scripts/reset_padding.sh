#!/bin/bash

# Called when displays are added or removed.
# Resets all spaces to normal padding and sets display-appropriate top padding.

NORMAL_PADDING=10

# Find the ultrawide dynamically by frame width (>3000px)
ULTRAWIDE_DISPLAY=$(yabai -m query --displays |
  /usr/bin/python3 -c "
import sys, json
displays = json.load(sys.stdin)
for d in displays:
    if d['frame']['w'] > 3000:
        print(d['index'])
        break
")

if [ -n "$ULTRAWIDE_DISPLAY" ]; then
  # Desk setup: extra gap below SketchyBar (33px bar + 10px gap)
  TOP_PADDING=43
else
  # Laptop only: bar sits flush, no extra gap needed
  TOP_PADDING=10
fi

yabai -m config top_padding $TOP_PADDING

# Reset left/right padding on all spaces
space_count=$(yabai -m query --spaces | jq 'length')
for i in $(seq 1 "$space_count"); do
  yabai -m config --space "$i" left_padding $NORMAL_PADDING
  yabai -m config --space "$i" right_padding $NORMAL_PADDING
done

"$HOME/.config/yabai/scripts/adjust_padding.sh"

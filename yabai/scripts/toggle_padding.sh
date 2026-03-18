#!/bin/bash

SINGLE_PADDING=600
NORMAL_PADDING=10

space_index=$(yabai -m query --spaces --space | jq '.index')
STATE_FILE="/tmp/yabai_padding_override_${space_index}"

if [ -f "$STATE_FILE" ]; then
  rm "$STATE_FILE"
  yabai -m config --space "$space_index" left_padding $NORMAL_PADDING
  yabai -m config --space "$space_index" right_padding $NORMAL_PADDING
else
  touch "$STATE_FILE"
  yabai -m config --space "$space_index" left_padding $SINGLE_PADDING
  yabai -m config --space "$space_index" right_padding $SINGLE_PADDING
fi

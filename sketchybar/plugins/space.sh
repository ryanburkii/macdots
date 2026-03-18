#!/bin/bash

# Highlight active space, dim inactive (matches latiarch waybar workspace opacity behavior)
if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" icon.highlight=on
else
  sketchybar --set "$NAME" icon.highlight=off
fi

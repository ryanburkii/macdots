#!/bin/bash

# Format: "Monday 14:30" — matches latiarch waybar clock format %A %H:%M
sketchybar --set "$NAME" label="$(date '+%A %H:%M')"

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

CPU=$(top -l 1 -n 0 | awk '/CPU usage/ {gsub(/%/,""); printf "%.0f", $3 + $5}')

sketchybar --set "$NAME" icon=󰍛
sketchybar --set cpu.detail label="${CPU}% CPU"

#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

THEMES=(nord rosepine catppuccin gruvbox-dark gruvbox-light)

case "$1" in
  toggle)
    CURRENT=$(cat "$HOME/.config/themes/current" 2>/dev/null | tr -d '[:space:]')
    for T in "${THEMES[@]}"; do
      if [[ "$T" == "$CURRENT" ]]; then
        sketchybar --set "theme.$T" icon.drawing=on
      else
        sketchybar --set "theme.$T" icon.drawing=off
      fi
    done
    sketchybar --set theme popup.drawing=toggle
    ;;
  pick)
    "$HOME/.config/themes/switch" "$2"
    sketchybar --set theme popup.drawing=off
    ;;
esac

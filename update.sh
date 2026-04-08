#!/bin/bash
set -e

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

GREEN='\033[0;32m'; NC='\033[0m'
info() { echo -e "${GREEN}→${NC} $*"; }

# ── Pull latest ───────────────────────────────────────────────────────────────
info "Pulling latest changes..."
git -C "$DOTS" pull

# ── Permissions (new scripts may have been added) ─────────────────────────────
chmod +x "$DOTS/themes/switch"
chmod +x "$DOTS/borders/bordersrc"
chmod +x "$DOTS/yabai/yabairc"
chmod +x "$DOTS/yabai/scripts/"*.sh
chmod +x "$DOTS/sketchybar/sketchybarrc"
chmod +x "$DOTS/sketchybar/plugins/"*.sh

# ── Re-sync textfox (CSS may have changed) ────────────────────────────────────
CURRENT=$(cat "$CONFIG/themes/current" 2>/dev/null || echo "nord")
FF_PROFILE=$(find "$HOME/Library/Application Support/Firefox/Profiles" \
  -maxdepth 1 -type d -name "*.textfox" 2>/dev/null | head -1)
if [[ -n "$FF_PROFILE" ]]; then
  cp "$DOTS/themes/textfox-${CURRENT}.css" "$FF_PROFILE/chrome/config.css"
  info "textfox updated"
fi

# ── Re-apply current theme (picks up any new color vars, sketchybar changes) ──
info "Re-applying theme: $CURRENT"
"$CONFIG/themes/switch" "$CURRENT"

info "Done! Restart Firefox if textfox changed."

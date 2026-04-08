#!/bin/bash
set -e

DOTS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info() { echo -e "${GREEN}→${NC} $*"; }
warn() { echo -e "${YELLOW}!${NC} $*"; }

# ── Homebrew ──────────────────────────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ── Dependencies ──────────────────────────────────────────────────────────────
info "Installing dependencies..."
brew tap koekeishiya/formulae 2>/dev/null || true
brew tap FelixKratz/formulae  2>/dev/null || true

brew install --quiet \
  koekeishiya/formulae/yabai \
  koekeishiya/formulae/skhd \
  FelixKratz/formulae/sketchybar \
  FelixKratz/formulae/borders \
  btop starship fastfetch neovim

brew install --cask --quiet ghostty 2>/dev/null || warn "Ghostty already installed or unavailable — install manually from ghostty.org"

# ── Symlink configs ───────────────────────────────────────────────────────────
info "Linking configs to ~/.config..."
mkdir -p "$CONFIG"

link() {
  local src="$1" dst="$2"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    warn "$dst exists — backing up to ${dst}.bak"
    mv "$dst" "${dst}.bak"
  fi
  if [[ ! -L "$dst" ]]; then
    ln -s "$src" "$dst"
    info "Linked $(basename "$dst")"
  fi
}

for dir in borders btop fastfetch ghostty nvim sketchybar skhd spotatui themes yabai; do
  link "$DOTS/$dir" "$CONFIG/$dir"
done
link "$DOTS/starship.toml" "$CONFIG/starship.toml"

# ── Permissions ───────────────────────────────────────────────────────────────
chmod +x "$DOTS/themes/switch"
chmod +x "$DOTS/borders/bordersrc"
chmod +x "$DOTS/yabai/yabairc"
chmod +x "$DOTS/yabai/scripts/"*.sh
chmod +x "$DOTS/sketchybar/sketchybarrc"
chmod +x "$DOTS/sketchybar/plugins/"*.sh

# ── textfox ───────────────────────────────────────────────────────────────────
FF_PROFILE=$(find "$HOME/Library/Application Support/Firefox/Profiles" \
  -maxdepth 1 -type d -name "*.textfox" 2>/dev/null | head -1)
if [[ -n "$FF_PROFILE" ]]; then
  info "Setting up textfox at $FF_PROFILE..."
  mkdir -p "$FF_PROFILE/chrome"
  cp "$DOTS/textfox/chrome/config.css" "$FF_PROFILE/chrome/config.css"
  cp "$DOTS/textfox/user.js"           "$FF_PROFILE/user.js"
else
  warn "No *.textfox Firefox profile found — skipping textfox"
  warn "Create a Firefox profile named 'textfox', then re-run to configure it"
fi

# ── Services ──────────────────────────────────────────────────────────────────
info "Starting services..."
yabai --start-service  2>/dev/null || true
skhd  --start-service  2>/dev/null || true
brew services start sketchybar 2>/dev/null || true
nohup "$CONFIG/borders/bordersrc" >/dev/null 2>&1 & disown

# ── Initial theme ─────────────────────────────────────────────────────────────
info "Applying nord theme..."
echo "nord" > "$CONFIG/themes/current"
"$CONFIG/themes/switch" nord

echo ""
info "Done! Restart Firefox to apply textfox."
info "Log out and back in if yabai/skhd need accessibility permissions."

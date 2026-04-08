eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias ls="eza -lh --group-directories-first --icons=auto"
alias lsa="ls -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias lta="lt -a"
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"
alias cd="zd"
zd() {
  if [ $# -eq 0 ]; then
    builtin cd ~ && return
  elif [ -d "$1" ]; then
    builtin cd "$1"
  else
    z "$@" && printf "\U000F17A9 " && pwd || echo "Error: Directory not found"
  fi
}
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}
export PATH="$HOME/.local/bin:$PATH"

# bat theme — mirrors current theme (source ~/.zshrc after switching themes)
case "$(cat ~/.config/themes/current 2>/dev/null)" in
  catppuccin)    export BAT_THEME="Catppuccin Latte" ;;
  nord)          export BAT_THEME="Nord" ;;
  rosepine)      export BAT_THEME="GitHub" ;;
  gruvbox-dark)  export BAT_THEME="gruvbox-dark" ;;
  gruvbox-light) export BAT_THEME="gruvbox-light" ;;
  *)             export BAT_THEME="Nord" ;;
esac

# fzf keybindings (Ctrl+R history, Ctrl+T file picker, Alt+C cd)
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
source /opt/homebrew/opt/fzf/shell/completion.zsh
export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons {}'"

# ZSH plugins (syntax-highlighting must be sourced last)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

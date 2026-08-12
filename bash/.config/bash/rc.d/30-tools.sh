# Optional tool integrations — each no-ops if the tool isn't installed.

# zoxide (smarter cd)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init bash)"

# nvm (Node version manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# pyenv (Python version manager)
if [ -d "$HOME/.pyenv" ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PYENV_ROOT/bin:$PATH"
  command -v pyenv >/dev/null 2>&1 && eval "$(pyenv init - bash)"
fi

# clipman clipboard history (Wayland only)
if command -v clipman >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
  wl-paste -p --watch clipman store --no-persist &
fi

# envman
[ -s "$HOME/.config/envman/load.sh" ] && . "$HOME/.config/envman/load.sh"

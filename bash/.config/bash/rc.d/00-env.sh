# Environment + PATH (portable)

export BASH_SILENCE_DEPRECATION_WARNING=1   # no-op off macOS; silences the zsh nag there

# dotnet global tools
if command -v dotnet >/dev/null 2>&1; then
  export PATH="$HOME/.dotnet/tools:$PATH"
fi

# dotfiles helper scripts on PATH
[ -d "$HOME/dotfiles/scripts" ] && export PATH="$HOME/dotfiles/scripts:$PATH"

# npm global packages (user prefix, no sudo)
export NPM_CONFIG_PREFIX="$HOME/.npm-global"
export PATH="$HOME/.npm-global/bin:$PATH"

# GNOME keyring SSH agent — only if it's actually running (Linux desktops)
if [ -n "$XDG_RUNTIME_DIR" ] && [ -S "$XDG_RUNTIME_DIR/keyring/ssh" ]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
  export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR/keyring"
fi

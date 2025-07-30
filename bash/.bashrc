#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias explorer='explorer.exe'
PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]$(pwd)\[\033[00m\]\$ '
# Add dotnet tools to PATH if dotnet is available
if command -v dotnet >/dev/null 2>&1; then
  export PATH="$HOME/.dotnet/tools:$PATH"
fi

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash)"
fi
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
export GNOME_KEYRING_CONTROL="$XDG_RUNTIME_DIR/keyring"

function cursor() {
    # Check if cursor binary actually exists, optional but good practice
    if ! command -v /usr/bin/cursor &> /dev/null
    then
        echo "Error: 'cursor' command not found."
        return 1
    fi

    # Execute the actual cursor command with all arguments in the background
    /usr/bin/cursor "$@" &
} 

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Initialize pyenv if available
if command -v pyenv >/dev/null 2>&1; then
  export PYENV_ROOT="$HOME/.pyenv"
  [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)"
fi
# Load git bash completion if available
if [ -f /usr/share/bash-completion/completions/git ]; then
  source /usr/share/bash-completion/completions/git
fi
# Useful alias for .bashrc/.zshrc
if command -v fzf >/dev/null 2>&1; then
  alias fcd='cd "$(find ~/ -type d | fzf)"'
  alias h="history | sed 's/^[ ]*[0-9]*[ ]*//' | fzf --tac --no-sort | xargs -r -I {} bash -c '{}'"
fi

# Start clipman if available
if command -v clipman >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
  wl-paste -p --watch clipman store --no-persist &
fi

# Check for git local config and show setup instructions if missing
check_git_local_config() {
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "⚠️  Git local config missing. Run these commands to set up:"
    echo "git config --file ~/.gitconfig.local user.name \"Your Name\""
    echo "git config --file ~/.gitconfig.local user.email \"your.email@domain.com\""
    echo ""
  fi
}
check_git_local_config

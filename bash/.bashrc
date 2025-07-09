#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias explorer='explorer.exe'
PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]$(pwd)\[\033[00m\]\$ '
export PATH="$HOME/.dotnet/tools:$PATH"

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

alias claude="/home/nick/.claude/local/claude"

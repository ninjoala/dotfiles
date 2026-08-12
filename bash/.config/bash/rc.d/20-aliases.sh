# Aliases (portable across GNU / BSD / WSL)

# Colored ls: GNU uses --color, BSD/macOS uses -G
if ls --color=auto >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi
alias grep='grep --color=auto'

# WSL only: open Windows Explorer from the shell
if grep -qiE '(microsoft|wsl)' /proc/version 2>/dev/null; then
  alias explorer='explorer.exe'
fi

# fzf-powered helpers (only if fzf is installed)
if command -v fzf >/dev/null 2>&1; then
  alias fcd='cd "$(find ~/ -type d | fzf)"'
  alias h="history | sed 's/^[ ]*[0-9]*[ ]*//' | fzf --tac --no-sort | xargs -r -I {} bash -c '{}'"
fi

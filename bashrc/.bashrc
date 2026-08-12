#
# ~/.bashrc — personal entrypoint for machines where YOU own this file
# (Debian / Ubuntu / WSL / macOS).
#
# NOTE: On Omarchy do NOT stow this package. Omarchy owns ~/.bashrc; instead add
# this line to the "add your own" section of Omarchy's ~/.bashrc:
#     [ -r ~/.config/bash/load.sh ] && . ~/.config/bash/load.sh
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# System-wide bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Load personal fragments (from the `bash` stow package)
[ -r ~/.config/bash/load.sh ] && . ~/.config/bash/load.sh

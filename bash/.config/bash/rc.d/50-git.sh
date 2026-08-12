# Git shell integration

# bash completion for git (path varies by distro; guarded)
for _c in /usr/share/bash-completion/completions/git \
          /usr/share/git/completion/git-completion.bash \
          /etc/bash_completion.d/git; do
  [ -f "$_c" ] && { . "$_c"; break; }
done
unset _c

# Remind to set a machine-local git identity (kept OUT of the repo via ~/.gitconfig.local)
check_git_local_config() {
  if [ ! -f "$HOME/.gitconfig.local" ]; then
    echo "⚠️  Git local config missing. Set it up with:"
    echo "    git config --file ~/.gitconfig.local user.name  \"Your Name\""
    echo "    git config --file ~/.gitconfig.local user.email \"you@example.com\""
    echo
  fi
}
check_git_local_config

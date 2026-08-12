# Personal shell functions

# Launch the Cursor editor detached from the terminal.
cursor() {
  if ! command -v /usr/bin/cursor >/dev/null 2>&1; then
    echo "Error: 'cursor' command not found." >&2
    return 1
  fi
  /usr/bin/cursor "$@" &
}

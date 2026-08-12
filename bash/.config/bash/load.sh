# Sourced by the active ~/.bashrc on every machine (Omarchy adds a line to its
# own bashrc; other machines get it via the `bashrc` stow package).
# Loads personal fragments in filename order.
for _f in ~/.config/bash/rc.d/*.sh; do
  [ -r "$_f" ] && . "$_f"
done
unset _f

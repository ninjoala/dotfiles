# Setup per machine

GNU stow layout. Clone to `~/dotfiles`, then stow the packages that apply.

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
```

## Bash: how it's structured (portable)

Bash config is split into two packages so it works everywhere:

- **`bash`** — the portable fragment library: `~/.config/bash/rc.d/*.sh` + `load.sh`.
  **Stow on every machine** (including Omarchy). Each fragment self-guards (OS/tool
  checks), so missing tools are skipped silently.
  - `10-prompt.sh` — delete this one file on a machine to use that host's default prompt.
- **`bashrc`** — the thin entrypoint (`~/.bashrc`, `~/.bash_profile`) that sources
  `load.sh`. **Stow only where you own `~/.bashrc`** (Debian / Ubuntu / WSL / macOS).

### Machine-local git identity (not in the repo)
```bash
git config --file ~/.gitconfig.local user.name  "Your Name"
git config --file ~/.gitconfig.local user.email "you@example.com"
```

---

## Omarchy (Arch + Hyprland)

Omarchy owns `~/.bashrc`, so **do not** stow the `bashrc` package. Instead:

```bash
# 1) prerequisites
omarchy pkg add stow zoxide fzf ripgrep fd     # tmux, neovim, git already present

# 2) portable core (NOT the bashrc entrypoint)
cd ~/dotfiles
stow bash git tmux tmux-sessionizer nvim

# 3) tell Omarchy's bashrc to load your fragments — add to the "add your own" section
#    of ~/.bashrc (one time, machine-local edit — Omarchy's file is not stowed):
#      [ -r ~/.config/bash/load.sh ] && . ~/.config/bash/load.sh
```

Do **NOT** stow on Omarchy (managed by Omarchy, would conflict/break theming):
`bashrc`, `hypr`, `waybar`, `.config` (mako). Terminal (`ghostty`) is **merged**, not
stowed — see below. Skip other-OS packages: `i3 polybar pulse aerospace glazewm zebar
windows-terminal`.

### Ghostty on Omarchy
Omarchy's `~/.config/ghostty/config` does live theming + a Hyprland perf fix. Don't
replace it — merge your prefs in (font-size, background opacity/blur, `ctrl+v` paste).

### nvim on Omarchy
Omarchy ships LazyVim. Stowing `nvim` replaces it with the personal config; back up
first: `mv ~/.config/nvim ~/.config/nvim.omarchy.bak`.

---

## Debian / Ubuntu / WSL2

```bash
sudo apt update
sudo apt install -y stow tmux fzf ripgrep fd-find build-essential curl git zoxide
cd ~/dotfiles
stow bash bashrc git tmux tmux-sessionizer nvim ghostty
```

Neovim: install 0.11+ from the official tarball (apt ships too old) — see repo notes.

## macOS

```bash
brew install stow tmux fzf ripgrep fd zoxide neovim
cd ~/dotfiles
stow bash bashrc git tmux tmux-sessionizer nvim ghostty aerospace
```

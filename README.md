# dotfiles

GNU stow layout. Each top-level directory mirrors `$HOME` and is symlinked into place with `stow <dir>`.

## Quick start

```bash
git clone <repo> ~/dotfiles
cd ~/dotfiles
```

Install prerequisites for the platform (see below), then symlink the configs you want:

```bash
# Run from the dotfiles root. Pick what applies to the machine.
stow bash zsh git tmux tmux-sessionizer nvim     # shells + core
stow ghostty                                      # terminal
stow i3 polybar pulse                             # Linux X11 desktop
stow hypr waybar                                  # Linux Wayland desktop
stow aerospace                                    # macOS
stow glazewm zebar windows-terminal               # Windows
```

`stow` will refuse if a real file already lives at the target — back it up or delete it first.

Finally, link Claude config:

```bash
bash .claude/setup.sh
ln -s ~/dotfiles/.claude ~/.claude-config
```

## Prerequisites

### Debian / Ubuntu / WSL2

```bash
sudo apt update
sudo apt install -y stow tmux fzf ripgrep fd-find build-essential curl git
```

**Do not install Neovim from apt** — Debian ships 0.10, but this config requires **Neovim 0.11+** (`mason-lspconfig` v2 calls `vim.lsp.enable()`, which doesn't exist on 0.10 and crashes on directory open).

Install Neovim from the official tarball instead:

```bash
NVIM_VERSION=v0.12.2   # bump as needed
curl -fsSL -o /tmp/nvim.tar.gz \
  "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"
sudo rm -rf /opt/nvim-linux-x86_64
sudo tar -C /opt -xzf /tmp/nvim.tar.gz
sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
nvim --version | head -1   # expect v0.11+
```

### Arch

```bash
sudo pacman -S stow tmux fzf ripgrep fd neovim base-devel git
```

### macOS

```bash
brew install stow tmux fzf ripgrep fd neovim git
```

## First nvim launch

Open `nvim` once. `lazy.nvim` bootstraps itself, installs all plugins, and Mason pulls down the LSP servers listed in `nvim/.config/nvim/lua/plugins/init.lua` (`lua_ls`, `pyright`, `ts_ls`, `html`, `cssls`, `jsonls`).

## Optional extras

- **C# LSP (`csharp_ls`)** — not enabled by default. Requires the .NET SDK (`sudo apt install dotnet-sdk-8.0` or equivalent) before adding `csharp_ls` back to `ensure_installed` and the manual server loop in `nvim/.config/nvim/lua/plugins/init.lua`.
- **OmniSharp** — see `OMNISHARP_PERFORMANCE.md` and `omnisharp.json.template`.
- **tmux-sessionizer paths** — edit `tmux-sessionizer/.config/tmux-sessionizer/tmux-sessionizer.conf` to point `TS_SEARCH_PATHS` at where you actually keep projects.

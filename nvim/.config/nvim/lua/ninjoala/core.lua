-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins
require("lazy").setup("plugins")

-- Setup Mason packages after plugins are loaded (simplified)
vim.api.nvim_create_autocmd("User", {
	pattern = "LazyDone",
	callback = function()
		-- Setup formatters and tools via mason.lua
		require("ninjoala.mason").setup()
	end,
})

-- Netrw settings
vim.g.netrw_keepj = ""
vim.g.netrw_fastbrowse = 0

-- Core Neovim settings
local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Tabs & Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true

-- Line wrapping
opt.wrap = false

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true

-- Cursor line
opt.cursorline = true

-- Appearance
opt.termguicolors = true
opt.background = "dark"
opt.signcolumn = "yes"

-- Backspace
opt.backspace = "indent,eol,start"

-- Clipboard
opt.clipboard:append("unnamedplus")

-- Split windows
opt.splitright = true
opt.splitbelow = true

-- Consider - as part of keyword
opt.iskeyword:append("-")

-- Disable swapfile
opt.swapfile = false

-- Faster key response times
opt.timeoutlen = 300 -- Time to wait for mapped sequence (default 1000ms)
opt.ttimeoutlen = 10 -- Time to wait for key codes like Escape (default 100ms)

-- Keep cursor centered
opt.scrolloff = 8 -- Keep 8 lines above/below cursor

-- Fast escape alternative
vim.keymap.set("i", "jk", "<Esc>", { noremap = true, silent = true })
vim.keymap.set("v", "jk", "<Esc>", { noremap = true, silent = true })


-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({'git','clone','--filter=blob:none','https://github.com/folke/lazy.nvim.git','--branch=stable',lazypath})
end
vim.opt.rtp:prepend(lazypath)

-- Set leader keys before loading plugins
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load plugins
require("lazy").setup("plugins")

-- Setup Mason packages after plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    require("ninjoala.mason").setup()
  end,
})

-- Netrw settings to fix jumplist behavior
vim.g.netrw_keepj = 1  -- Don't add netrw browsing to the jumplist
vim.g.netrw_fastbrowse = 0  -- Don't reuse netrw buffers (cleaner jumplist)

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
opt.hlsearch = true
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
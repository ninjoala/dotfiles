-- Basic settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.mouse = 'a'
vim.opt.termguicolors = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

-- Set leader key to space
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Enable syntax highlighting
vim.cmd('syntax on')

-- Enable filetype detection and plugins
vim.cmd('filetype plugin indent on') 
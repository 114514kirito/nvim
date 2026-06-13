-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Indent: 4 spaces
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = false -- off: conflicts with treesitter indent in C/C++

-- Keep 8 lines of context above/below cursor
vim.opt.scrolloff = 8

-- Show matching bracket briefly
vim.opt.showmatch = true

-- Disable all bells and screen flashes
vim.opt.errorbells = false
vim.opt.visualbell = false
vim.opt.belloff = "all"

-- Modern Neovim defaults
vim.opt.cursorline = true -- highlight current line
vim.opt.cursorlineopt = "number" -- only highlight line number (cleaner)
vim.opt.wrap = false -- don't wrap long lines
vim.opt.signcolumn = "yes" -- always show sign column (avoids text shifting)

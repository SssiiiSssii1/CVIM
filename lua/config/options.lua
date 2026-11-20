vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"

vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"

vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.hidden = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

vim.opt.termguicolors = true
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.confirm = true
vim.opt.wrap = false

-- Keep enough history for Snacks recent files and normal editing, but do not
-- persist temporary or private paths.
vim.opt.shada = "!,'200,<50,s10,h,r/tmp/,r/private/"

-- Nerd Font glyphs should occupy a single cell, and floating windows should
-- use a consistent rounded border.
vim.opt.ambiwidth = "single"
vim.opt.winborder = "rounded"

-- Empty lines should not be filled with "~" markers.
vim.opt.fillchars:append({ eob = " " })

-- Quiet startup/checkhealth by disabling providers this config does not use.
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_perl_provider = 1
vim.g.loaded_python3_provider = 1
vim.g.loaded_ruby_provider = 1
vim.g.loaded_node_provider = 1

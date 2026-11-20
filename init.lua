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

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.competitive").setup()
require("config.lazy")

vim.g.mapleader = " "

-- Keep enough history for Snacks recent files and normal editing, but do not
-- persist temporary or private paths.
vim.opt.shada = "!,'200,<50,s10,h,r/tmp/,r/private/"

-- Nerd Font glyphs should occupy a single cell, and floating windows should
-- use a consistent rounded border.
vim.opt.ambiwidth = "single"
vim.opt.winborder = "rounded"

-- Quiet startup/checkhealth by disabling providers this config does not use.
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tohtml = 1
vim.g.loaded_perl_provider = 1
vim.g.loaded_python3_provider = 1
vim.g.loaded_ruby_provider = 1
vim.g.loaded_node_provider = 1

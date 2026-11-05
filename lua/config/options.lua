-- Options are automatically loaded before lazy.nvim startup.
-- LazyVim already enables the important beginner defaults:
--   line numbers + relative numbers, mouse support, system clipboard,
--   undo history, a global statusline, case-insensitive smart search,
--   and 2-space indentation.
--
-- Only add options here that improve the defaults for your workflow.

-- LazyVim formats on BufWritePre through conform.nvim. Keep autoformat enabled
-- globally; toggle it temporarily with <leader>uf (global) or <leader>uF (buffer).
vim.g.autoformat = true

-- Keep a little context around the cursor.
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8

-- Make wrapped lines easier to read.
vim.opt.breakindent = true

-- Terminal font rendering.
-- The terminal uses JetBrainsMono Nerd Font Mono. Tell LazyVim to use the
-- Nerd Font icon set explicitly instead of relying on a terminal fallback.
vim.g.have_nerd_font = true
-- Nerd Font icons are single-width. "double" makes them overlap in a terminal.
vim.opt.ambiwidth = "single"
-- Required for the colorscheme and icon colors to render correctly.
vim.opt.termguicolors = true

-- Rounded borders for hover, diagnostics, and other floating windows.
vim.opt.winborder = "rounded"

-- Remember recently opened files for the dashboard and `:oldfiles`.
-- The `r/tmp/` and `r/private/` filters keep temporary files out.
vim.opt.shada = "!,'200,<50,s10,h,r/tmp/,r/private/"

-- This setup does not use Neovim's optional Node, Perl, Python, or Ruby
-- providers. Disabling them keeps :checkhealth focused on real issues.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

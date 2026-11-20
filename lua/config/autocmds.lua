-- Filetype-specific indentation. Go uses tabs; C/C++/Rust use four spaces.
local indent_group = vim.api.nvim_create_augroup("filetype_indent", { clear = true })

-- colorcolumn is window-local, so it must be reset when the window changes
-- to a different filetype instead of lingering from a previous C++ buffer.
vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = "*",
  callback = function(args)
    local long_lines = vim.tbl_contains({ "c", "cpp", "rust" }, vim.bo[args.buf].filetype)
    vim.wo.colorcolumn = long_lines and "120" or ""
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    vim.bo.expandtab = false
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = indent_group,
  pattern = { "c", "cpp", "rust" },
  callback = function()
    vim.bo.expandtab = true
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
    vim.bo.softtabstop = 4
  end,
})

-- Docker Compose files are YAML, but the Compose language server only starts
-- for the yaml.docker-compose filetype.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function(args)
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":t")
    if name:match("^docker%-compose.*%.ya?ml$") or name:match("^compose.*%.ya?ml$") then
      vim.bo[args.buf].filetype = "yaml.docker-compose"
    end
  end,
})

vim.treesitter.language.register("yaml", "yaml.docker-compose")

-- nvim-treesitter has no dedicated JSONC parser; JSON5 handles comments and
-- trailing commas.
vim.treesitter.language.register("json5", "jsonc")

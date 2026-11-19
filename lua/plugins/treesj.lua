-- Split and join blocks using tree-sitter (function arguments, objects,
-- arrays, ...). Toggle with <leader>cj on the block under the cursor.
return {
  "Wansmer/treesj",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  keys = {
    { "<leader>cj", "<cmd>TSJToggle<cr>", desc = "Split/Join Block" },
  },
  opts = {
    use_default_keymaps = false,
    notify = false,
  },
}

-- Small quality-of-life UI additions.
return {
  -- Show recent key presses in the corner: handy while learning Vim.
  {
    "nvchad/showkeys",
    cmd = "ShowkeysToggle",
    keys = {
      { "<leader>uk", "<cmd>ShowkeysToggle<cr>", desc = "Toggle Show Keys" },
    },
    opts = {
      timeout = 2,
      maxkeys = 5,
      position = "bottom-right",
      show_count = true,
      winopts = { border = "rounded" },
    },
  },
  -- A subtle 120-column ruler. Matches the C/C++ fallback column limit and
  -- keeps long lines visible without adding a hard wrap.
  {
    "lukas-reineke/virt-column.nvim",
    event = "VeryLazy",
    opts = {
      char = { "┆" },
      virtcolumn = "120",
      highlight = { "NonText" },
    },
  },
}

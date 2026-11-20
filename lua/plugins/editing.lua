-- Editing helpers. Global keymaps live in lua/config/keymaps.lua; these specs
-- only configure the plugins and deliberately disable Flash's default s/S keys
-- so native Vim substitute/change commands are preserved.

return {
  {
    "nvim-mini/mini.comment",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = false },
        search = { enabled = false },
        treesitter = { enabled = false },
      },
    },
  },
}

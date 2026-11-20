return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      delay = 300,
      preset = "modern",
      win = {
        -- Which-key v3 has no `position` option; col/row are the supported keys.
        -- col = -1 anchors the popup to the right edge.
        col = -1,
        row = 1,
        width = { min = 30, max = 60 },
        border = "rounded",
      },
    },
    config = function(_, opts)
      -- Set which-key up first, then register the custom group labels through
      -- its public add() API. No startup pcall hides registration failures.
      require("which-key").setup(opts)
      require("config.keymaps").register_groups()
    end,
  },
}

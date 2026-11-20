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
  },
}

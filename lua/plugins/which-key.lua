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
      -- which-key v3 queues specs added with add() until setup() runs, so add
      -- the group specs first and let setup() install them in one pass.
      require("config.keymaps").register_groups()
      require("which-key").setup(opts)
    end,
  },
}

-- Better quickfix window: syntax highlighting, context lines, and
-- < / > to collapse or expand the surrounding code.
return {
  "stevearc/quicker.nvim",
  ft = "qf",
  opts = {
    keys = {
      {
        ">",
        function()
          require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
    },
  },
}

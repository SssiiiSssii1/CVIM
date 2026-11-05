-- Make the terminal toggle (Ctrl+/) open as a vertical split on the right.
-- Lazygit (<leader>gg) runs on the same snacks terminal machinery, so the
-- terminal override above would leak into it; the explicit `lazygit`
-- section pins lazygit back to the stock centered float.
return {
  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        win = {
          position = "right",
          width = 0.35, -- 35% of the screen (use a number like 60 for a fixed width)
        },
      },
      lazygit = {
        win = {
          position = "float",
          -- Stock LazyVim look: big centered popup, rounded border,
          -- floating over the code instead of a bottom/right split.
          width = 0.9,
          height = 0.9,
        },
      },
    },
  },
}

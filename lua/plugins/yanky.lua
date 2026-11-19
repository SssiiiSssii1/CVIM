-- Yank history with a ring buffer: cycle through old yanks, paste older
-- entries, and survive restarts.
--
-- LazyVim's `coding.yanky` extra maps the history picker to <leader>p,
-- which this config already uses for the command palette, so this spec uses
-- <leader>sy instead. The y/p/P replacements below come from the LazyVim
-- extra and keep normal Neovim behaviour while feeding the ring.
return {
  "gbprod/yanky.nvim",
  event = "LazyFile",
  opts = {
    ring = {
      history = 100,
      storage = "shada",
      sync_with_numbered_registers = true,
    },
    system_clipboard = {
      sync_with_ring = not vim.env.SSH_CONNECTION,
    },
    highlight = { timer = 150 },
  },
  keys = {
    {
      "<leader>sy",
      function()
        Snacks.picker.yanky()
      end,
      mode = { "n", "x" },
      desc = "Yank History",
    },
    -- stylua: ignore
    { "y", "<Plug>(YankyYank)", mode = { "n", "x" } },
    { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" } },
    { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" } },
    { "gp", "<Plug>(YankyGPutAfter)", mode = { "n", "x" } },
    { "gP", "<Plug>(YankyGPutBefore)", mode = { "n", "x" } },
    { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
    { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
    { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
    { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
    { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
    { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
    { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
    { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
  },
}

-- Hide secrets in .env-style files so screen sharing and screenshots do not
-- leak API keys. Toggle the masks with <leader>uK.
return {
  "laytan/cloak.nvim",
  keys = {
    { "<leader>uK", "<cmd>CloakToggle<CR>", desc = "Toggle Secret Masks" },
  },
  opts = {
    enabled = true,
    cloak_character = "*",
    highlight_group = "Comment",
    patterns = {
      {
        file_pattern = {
          ".env*",
          "wrangler.toml",
          ".dev.vars",
        },
        cloak_pattern = "=.+",
      },
    },
  },
}

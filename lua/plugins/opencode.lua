-- OpenCode integration: https://github.com/nickjvandyke/opencode.nvim
-- Requires the `opencode` CLI (v2) to be installed and on PATH.
local function terminal_opts(enter)
  return {
    win = {
      position = "right",
      enter = enter,
    },
  }
end

local function toggle_opencode()
  -- Create the terminal if needed, focus it, or hide it when already focused.
  require("snacks.terminal").focus("opencode", terminal_opts(true))
end

return {
  "nickjvandyke/opencode.nvim",
  keys = {
    { "<leader>a", "", desc = "+opencode", mode = { "n", "v" } },
    {
      "<leader>aa",
      function()
        require("opencode").ask("@this: ")
      end,
      mode = { "n", "v" },
      desc = "Ask OpenCode",
    },
    {
      "<leader>as",
      function()
        require("opencode").select()
      end,
      mode = { "n", "v" },
      desc = "Select OpenCode action",
    },
    {
      "<leader>ao",
      function()
        return require("opencode").operator("@this")
      end,
      mode = { "n", "v" },
      expr = true,
      desc = "Send to OpenCode",
    },
    { "<leader>at", toggle_opencode, desc = "Toggle OpenCode" },
  },
  init = function()
    vim.g.opencode_opts = {
      server = {
        start = function()
          -- Start the OpenCode TUI in a right split without stealing focus.
          require("snacks.terminal").open("opencode", terminal_opts(false))
        end,
      },
    }
  end,
}

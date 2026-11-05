-- Discord Rich Presence via cord.nvim.
--
-- What this setup adds over the defaults:
--   * Catppuccin icon theme (matches the editor colorscheme).
--   * Cumulative, per-project elapsed time: the persistent_timer extension
--     tracks active coding time per workspace ACROSS Neovim sessions, so
--     Discord shows "N hrs M mins" of real time on the project, not just
--     time since this session started. Data is saved to disk.
--   * A "View Repository" button that appears only when the project has a
--     Git remote (cord resolves opts.repo_url via git).
--   * Live problem counts from the diagnostics extension ("Editing a file
--     - 2 problems").
--   * Native NestJS detection via cord's resolver extension; the old
--     hand-rolled autocmd REPLACED above by it. The resolver also detects
--     toggleterm buffers better than the defaults.
--   * Auto-reconnect when Discord starts after Neovim.
--
-- Settings changes require `:Cord restart` (or a Neovim restart).

return {
  "vyfor/cord.nvim",
  build = ":Cord update",
  event = "VeryLazy",

  opts = function()
    local icon = require("cord.api.icon")

    return {
      editor = {
        client = "lazyvim",
        tooltip = "The Superior Text Editor",
      },

      display = {
        theme = "catppuccin",
        flavor = "dark",
      },

      -- The persistent_timer extension (below) overwrites the timestamp with
      -- cumulative per-project active time; this core option must stay on so
      -- Discord is told to render an elapsed clock at all.
      timestamp = { enabled = true },

      idle = {
        enabled = true,
        timeout = 300000, -- 5 minutes, same as the default
        show_status = true,
        -- smart_idle / unidle_on_focus / ignore_focus keep their defaults,
        -- which behave best for multi-instance and general use.
        details = function()
          local messages = {
            "Taking a tea break",
            "Debugging in my head",
            "Compiling thoughts",
            "Lost in the matrix",
            "Buffering...",
            "Probably on YouTube",
            "Touching grass",
            "Refactoring life decisions",
          }
          return messages[math.random(#messages)]
        end,
        icon = icon.get("keyboard", "catppuccin", "dark"),
      },

      text = {
        -- Privacy: never show the project name; only file-level activity
        -- with problem counts (the NestJS project type is still detected so
        -- the asset match is right, but no workspace text leaks).
        workspace = "",
        viewing = function(opts)
          return "Viewing a file - " .. opts.diagnostics(opts) .. " problems"
        end,
        editing = function(opts)
          return "Editing a file - " .. opts.diagnostics(opts) .. " problems"
        end,
        file_browser = "Browsing files",
        plugin_manager = "Managing plugins",
        lsp = "Configuring LSP",
        docs = "Reading docs",
        vcs = "Committing changes",
        notes = "Taking notes",
        debug = "Debugging",
        test = "Testing",
        diagnostics = "Fixing problems",
        terminal = "Running commands",
        dashboard = "Home",
      },

      -- Only rendered when opts.repo_url is set (a Git remote was found),
      -- otherwise Discord shows no button.
      buttons = {
        { label = "View Repository", url = function(opts) return opts.repo_url end },
      },

      extensions = {
        -- Built-in workspace detectors. `true` enables every source; oil is
        -- only for the oil.nvim plugin, which this config does not use.
        resolver = { sources = { true, oil = false } },
        -- Problem counts used by the editing/viewing text functions.
        -- override = false so the text above stays in charge.
        diagnostics = {
          scope = "buffer",
          severity = { min = vim.diagnostic.severity.WARN },
          override = false,
        },
        -- Cumulative active time per workspace across sessions. mode =
        -- "active" only counts minutes where you actually typed/moved, so
        -- the timer is not ticking while Neovim idles untouched.
        persistent_timer = {
          scope = "workspace",
          mode = "active",
          save_on = { "exit", "focus_change", "periodic" },
          save_interval = 30,
        },
      },

      advanced = {
        discord = {
          reconnect = { enabled = true }, -- Discord opened after Neovim
        },
      },
    }
  end,
}

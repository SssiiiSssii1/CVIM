-- Small, beginner-focused UI additions on top of LazyVim.
-- Keep this file short: most behavior still comes from LazyVim defaults.
return {
  {
    "snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}

      -- Square Kufic "العلم قبل القول والعمل" (knowledge before words and deeds).
      -- This is the compact 33x9 artwork used by NvChad.
      -- Snacks expects the header as a newline-delimited string; a plain list
      -- of lines would only render its first entry.
      local kufic_header = {
        "           ▄ ▄                   ",
        "       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
        "       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
        "    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
        "  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
        "  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
        "▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
        "█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
        "    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
      }
      opts.dashboard.formats = opts.dashboard.formats or {}
      opts.dashboard.formats.header = { "%s", align = "center" }
      opts.dashboard.preset.header = table.concat(kufic_header, "\n")

      -- Ten essentials. Keeping the list short and gap-free means the whole
      -- dashboard fits on a small laptop screen without clipping.
      opts.dashboard.preset.keys = {
        { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
        { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
        { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
        { icon = " ", key = "p", desc = "Projects", action = ":lua Snacks.picker.projects()" },
        {
          icon = " ",
          key = "c",
          desc = "Config",
          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
        },
        { icon = " ", key = "l", desc = "Lazy", action = ":Lazy" },
        { icon = " ", key = "t", desc = "Vim Tutor", action = ":Tutor" },
        {
          icon = " ",
          key = "b",
          desc = "Beginner Guide",
          action = function()
            vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/BEGINNER_GUIDE.md"))
          end,
        },
        {
          icon = " ",
          key = "k",
          desc = "All Keymaps",
          action = function()
            require("which-key").show({ global = true })
          end,
        },
        { icon = " ", key = "q", desc = "Quit", action = ":qa" },
      }

      -- Compact sections. gap = 0 removes the blank line between each key,
      -- which was the main reason the old dashboard overflowed.
      opts.dashboard.sections = {
        { header = opts.dashboard.preset.header, padding = 1, align = "center" },
        { section = "keys", gap = 0, padding = 1 },
        {
          section = "recent_files",
          icon = " ",
          title = "Recent Files",
          indent = 2,
          padding = 1,
          limit = 5,
        },
        {
          section = "projects",
          icon = " ",
          title = "Projects",
          indent = 2,
          padding = 1,
          limit = 3,
        },
        { section = "startup" },
      }

      -- Keep the file explorer narrow and preview-free so the editor gets
      -- most of the width. The default sidebar is 40 columns.
      opts.picker = opts.picker or {}
      opts.picker.sources = opts.picker.sources or {}
      opts.picker.sources.explorer = vim.tbl_deep_extend("force", opts.picker.sources.explorer or {}, {
        layout = {
          preset = "sidebar",
          preview = false,
          layout = { width = 32, min_width = 32 },
        },
        -- Untracked files are common in new projects; the "?" markers add
        -- noise without helping a beginner. Modified/staged files still show.
        git_untracked = false,
      })

      return opts
    end,
  },
}

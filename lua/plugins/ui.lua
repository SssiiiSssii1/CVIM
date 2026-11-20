return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    dependencies = {
      { "nvim-mini/mini.icons", opts = {} },
    },
    opts = {
      explorer = {
        enabled = true,
      },
      terminal = {
        win = {
          position = "right",
          width = 0.35,
        },
      },
      lazygit = {
        win = {
          position = "float",
          width = 0.9,
          height = 0.9,
        },
      },
      picker = {
        sources = {
          explorer = {
            layout = {
              preset = "sidebar",
              preview = false,
              layout = { width = 32, min_width = 32 },
            },
            git_untracked = false,
            win = {
              input = {
                keys = {
                  -- Move between the Explorer input and its list. Other pickers
                  -- keep Snacks' default <C-j>/<C-k> list navigation.
                  ["<C-j>"] = "focus_list",
                  ["<C-k>"] = "focus_input",
                },
              },
              list = {
                keys = {
                  ["<C-j>"] = "focus_list",
                  ["<C-k>"] = "focus_input",
                },
              },
            },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          header = table.concat({
            "           ▄ ▄                   ",
            "       ▄   ▄▄▄     ▄ ▄▄▄ ▄ ▄     ",
            "       █ ▄ █▄█ ▄▄▄ █ █▄█ █ █     ",
            "    ▄▄ █▄█▄▄▄█ █▄█▄█▄▄█▄▄█ █     ",
            "  ▄ █▄▄█ ▄ ▄▄ ▄█ ▄▄▄▄▄▄▄▄▄▄▄▄▄▄  ",
            "  █▄▄▄▄ ▄▄▄ █ ▄ ▄▄▄ ▄ ▄▄▄ ▄ ▄ █ ▄",
            "▄ █ █▄█ █▄█ █ █ █▄█ █ █▄█ ▄▄▄ █ █",
            "█▄█ ▄ █▄▄█▄▄█ █ ▄▄█ █ ▄ █ █▄█▄█ █",
            "    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█ █▄█▄▄▄█    ",
          }, "\n"),
          -- CVIM's compact key list, minus the LazyVim-only Beginner Guide.
          keys = {
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
              icon = " ",
              key = "k",
              desc = "All Keymaps",
              action = function()
                require("which-key").show({ global = true })
              end,
            },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
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
        },
      },
      notifier = {
        enabled = true,
      },
      input = {
        enabled = true,
      },
      indent = {
        enabled = true,
      },
    },
    config = function(_, opts)
      require("snacks").setup(opts)

      -- Snacks Explorer is a picker, so it uses the SnacksPicker* groups.
      -- Cyberdream's transparent mode removes every float background, which
      -- leaves Explorer text sitting directly on the terminal background.
      -- Give just the picker windows Cyberdream's own bg_alt panel and use
      -- neutral/semantic palette colors for the text.
      local function picker_palette()
        local colors = require("cyberdream.colors")
        local ok_config, cyberdream = pcall(require, "cyberdream.config")
        local opts = ok_config and cyberdream.options or {}

        local active = opts.variant or "auto"
        local palette_name = active
        if palette_name == "auto" then
          palette_name = vim.o.background == "light" and "light" or "default"
        elseif palette_name == "dark" then
          palette_name = "default"
        end

        local palette = vim.deepcopy(colors[palette_name] or colors.default)

        local ok_util, util = pcall(require, "cyberdream.util")
        if ok_util and opts.saturation and util.apply_saturation then
          palette = util.apply_saturation(palette, opts.saturation)
        end

        local overrides = opts.colors or {}
        local general = vim.tbl_deep_extend("keep", {}, overrides)
        for _, key in ipairs({ "dark", "light", "muted", "auto", "default" }) do
          general[key] = nil
        end
        palette = vim.tbl_deep_extend("force", palette, general)

        -- Mirror Cyberdream's own override lookup: "auto" on a dark background
        -- and the literal "dark" variant both use the `dark` override when it
        -- exists, falling back to the legacy `default` key.
        local lookup = active == "auto" and vim.o.background or active
        if lookup == "default" or lookup == "dark" then
          lookup = overrides.dark and "dark" or "default"
        end
        palette = vim.tbl_deep_extend("force", palette, overrides[lookup] or {})

        return palette
      end

      local function set_picker_highlights()
        local p = picker_palette()
        local function set(name, values)
          values.link = ""
          vim.api.nvim_set_hl(0, name, values)
        end

        for _, name in ipairs({
          "SnacksPickerNormal",
          "SnacksPickerList",
          "SnacksPickerInput",
          "SnacksPickerPreview",
          "SnacksPickerBox",
          "SnacksPickerBorder",
        }) do
          set(name, { bg = p.bg_alt, fg = p.fg })
        end

        set("SnacksPickerListCursorLine", { bg = p.bg_highlight, fg = p.fg })
        set("SnacksPickerFile", { fg = p.fg })
        set("SnacksPickerDirectory", { fg = p.blue })
        set("SnacksPickerDir", { fg = p.grey })
        set("SnacksPickerIconFile", { fg = p.blue })

        -- Snacks defines these as lazy default links, so reading them here
        -- returns no foreground. Pick explicit Cyberdream semantic colors so
        -- the panel background does not flatten every Git marker to white.
        for name, color in pairs({
          SnacksPickerGitStatus = p.cyan,
          SnacksPickerGitStatusAdded = p.green,
          SnacksPickerGitStatusModified = p.yellow,
          SnacksPickerGitStatusDeleted = p.red,
          SnacksPickerGitStatusRenamed = p.blue,
          SnacksPickerGitStatusCopied = p.cyan,
          SnacksPickerGitStatusUntracked = p.grey,
          SnacksPickerGitStatusIgnored = p.grey,
          SnacksPickerGitStatusUnmerged = p.red,
          SnacksPickerGitStatusStaged = p.cyan,
        }) do
          set(name, { fg = color, bg = p.bg_alt })
        end
      end

      set_picker_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("snacks_picker_highlights", { clear = true }),
        callback = set_picker_highlights,
      })
    end,
  },
}

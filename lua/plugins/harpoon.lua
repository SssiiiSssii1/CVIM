-- Harpoon 2: pin a small set of project files and jump to them instantly.
--
-- LazyVim ships this as the `editor.harpoon2` extra, but that extra maps
-- <leader>H, which this config already uses for the beginner guide. The
-- keymaps below keep harpoon's workflow on free keys:
--   <leader>ha  add the current file
--   <leader>hh  open the quick menu
--   <leader>1-9 jump to a pinned file
--
-- Nothing loads until one of those keys is pressed.
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {
    menu = {
      width = 80,
    },
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon: Add File",
      },
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon: Quick Menu",
      },
    }

    for i = 1, 9 do
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon: File " .. i,
      })
    end

    return keys
  end,
}

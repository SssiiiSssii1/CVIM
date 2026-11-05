-- Keymaps are automatically loaded on the VeryLazy event.
-- LazyVim already provides the core shortcuts used in the guide:
--   <C-s> save, <leader><space> find files, <leader>/ search text,
--   <leader>e explorer, <leader>, buffers, <leader>gg lazygit,
--   gd definition, gr references, K hover, <leader>ca code action,
--   <leader>cr rename, <leader>cf format, <leader>cd diagnostics.
--
-- Add only the few extra habits that are useful for a VS Code user.

-- Ctrl+P: find files. This is the shortcut most people try first.
vim.keymap.set("n", "<C-p>", function()
  Snacks.picker.files()
end, { desc = "Find Files" })

-- <leader>p: command palette. Search and run any Neovim command.
vim.keymap.set("n", "<leader>p", function()
  Snacks.picker.commands()
end, { desc = "Command Palette" })

-- <leader>H: open the beginner guide stored next to this config.
vim.keymap.set("n", "<leader>H", function()
  vim.cmd.edit(vim.fn.fnameescape(vim.fn.stdpath("config") .. "/BEGINNER_GUIDE.md"))
end, { desc = "Beginner Guide" })

-- <leader>gC: browse and checkout a Git branch without leaving Neovim.
vim.keymap.set("n", "<leader>gC", function()
  Snacks.picker.git_branches()
end, { desc = "Git Branches" })

-- <leader>rn: create a new C++ competitive-programming file.
vim.keymap.set("n", "<leader>rn", function()
  require("config.competitive").new_prompt()
end, { desc = "CP: New File" })

-- Give the buffer-local C++ run maps a visible which-key group.
pcall(function()
  require("which-key").add({
    { "<leader>r", group = "Run / CP" },
  })
end)

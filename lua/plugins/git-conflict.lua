-- Merge-conflict helper. Adds buffer-local mappings inside conflicted files:
--   co  choose ours      ct  choose theirs
--   cb  choose both      c0  choose none
--   ]x / [x  next/prev conflict
return {
  "akinsho/git-conflict.nvim",
  version = "*",
  event = "BufReadPre",
  opts = {
    default_mappings = true,
    disable_diagnostics = false,
    list_opener = "copen",
    highlights = {
      incoming = "DiffAdd",
      current = "DiffText",
      ancestor = "DiffChange",
    },
  },
}

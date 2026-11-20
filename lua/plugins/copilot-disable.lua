-- Disable GitHub Copilot's AI-generated inline suggestions and AI completion
-- sources while keeping blink.cmp fully functional:
-- LSP suggestions, snippets, diagnostics, auto-imports and the normal
-- completion sources (lsp, path, snippets, buffer, dadbod) all stay enabled.
-- opencode.nvim is a separate plugin and is not touched here.

return {
  -- copilot.lua: ghost text / inline AI suggestions
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = {
        enabled = false,
        auto_trigger = false,
      },
    },
  },

  -- blink.cmp: remove the "copilot" AI source from the sources list while
  -- keeping everything LazyVim and the lang.sql extra added there.
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local sources = opts and opts.sources or {}
      local default = {}
      for _, name in ipairs(sources.default or {}) do
        if name ~= "copilot" then
          table.insert(default, name)
        end
      end
      opts = opts or {}
      opts.sources = sources
      opts.sources.default = default
      if opts.sources.providers and opts.sources.providers.copilot then
        opts.sources.providers.copilot = nil
      end
      return opts
    end,
  },

  -- blink-copilot: the AI completion source integrated into blink.cpp.
  -- copilot is no longer part of the sources list above, so disable it too.
  {
    "blink-copilot",
    enabled = false,
  },
}

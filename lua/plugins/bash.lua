-- Bash / shell support.
--
-- LazyVim has no Bash language extra. bash-language-server provides
-- completion, hover, diagnostics, and shellcheck integration. shfmt is
-- already wired up by LazyVim's conform.nvim defaults, and shellcheck is
-- used by bashls so it does not need a second nvim-lint entry.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bashls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "bash-language-server",
        "shellcheck",
      },
    },
  },
}

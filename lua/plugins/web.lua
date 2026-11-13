-- HTML, CSS, and Emmet support for React/Next.js frontends.
--
-- These are the official LSP servers packaged by Mason, configured through
-- nvim-lspconfig (no extra plugin). They provide HTML/CSS completion, hover,
-- diagnostics, and Emmet abbreviation expansion inside HTML, CSS, TSX, and
-- JSX. Formatting stays with conform/Prettier or Biome; LazyVim's
-- `lsp_format = "fallback"` means html/cssls only format when no conform
-- formatter is available.
--
-- `unknownAtRules` is ignored in CSS/SCSS because Tailwind v3/v4 directives
-- (`@tailwind`, `@apply`, `@theme`, `@layer`, ...) are not known to the
-- vanilla CSS language service. All other CSS validation remains enabled.
-- Emmet's default root marker is `.git` only; package.json is added so it also
-- starts in projects that are not git repositories.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        html = {},
        cssls = {
          settings = {
            css = { validate = true, lint = { unknownAtRules = "ignore" } },
            scss = { validate = true, lint = { unknownAtRules = "ignore" } },
          },
        },
        emmet_language_server = {
          root_markers = { "package.json", ".git" },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "css-lsp",
        "emmet-language-server",
        "html-lsp",
      },
    },
  },
  {
    -- LazyVim installs the JavaScript/TypeScript/HTML/JSON/YAML/Markdown
    -- parsers. CSS and SCSS are the only web parsers missing from its base
    -- list, and they are used by Tailwind directives and `className` strings.
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "css", "scss" } },
  },
}

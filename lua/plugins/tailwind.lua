-- Tailwind CSS IntelliSense (Tailwind v3 and v4).
--
-- LazyVim's lang.tailwind extra supplies the nvim-lspconfig server definition
-- and excludes markdown. Tailwind v4 projects have no tailwind.config.* file;
-- nvim-lspconfig falls back to the nearest .git/package.json root and the
-- language server finds the CSS entry point that contains
-- `@import "tailwindcss"`.
--
-- classFunctions teaches the server about utility wrappers used by common
-- React libraries (clsx, class-variance-authority, tailwind-merge,
-- tailwind-variants). classAttributes keeps JSX `className` working even if a
-- future server default changes.
--
-- Tailwind LS 0.16 does not advertise textDocument/documentColor, so
-- Neovim's built-in vim.lsp.document_color cannot render class colors.
-- mini.hipatterns supplies the visible color previews (see
-- lua/plugins/hipatterns.lua). `colorDecorators` stays enabled for server
-- versions that do support the capability, and is harmless otherwise.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          settings = {
            tailwindCSS = {
              validate = true,
              suggestions = true,
              hovers = true,
              codeActions = true,
              colorDecorators = true,
              showPixelEquivalents = true,
              rootFontSize = 16,
              -- Emmet is handled by emmet-language-server, so do not emit a
              -- second copy of the same abbreviations from Tailwind.
              emmetCompletions = false,
              classAttributes = {
                "class",
                "className",
                "class:list",
                "classList",
                "ngClass",
              },
              classFunctions = {
                "clsx",
                "cn",
                "cva",
                "cx",
                "tw",
                "twMerge",
                "tv",
              },
              lint = {
                cssConflict = "warning",
                invalidApply = "error",
                invalidScreen = "error",
                invalidVariant = "error",
                invalidConfigPath = "error",
                invalidTailwindDirective = "error",
                recommendedVariantOrder = "warning",
              },
            },
          },
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "tailwindcss-language-server" } },
  },
}

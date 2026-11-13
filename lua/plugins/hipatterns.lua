-- Tailwind color previews.
--
-- Tailwind's language server does not advertise textDocument/documentColor,
-- so Neovim's built-in vim.lsp.document_color cannot render Tailwind classes.
-- LazyVim's official mini-hipatterns extra fills that gap: it highlights
-- standard utility colors (bg-red-500, text-emerald-300, ...) and literal
-- hex colors such as arbitrary values like bg-[#123456].
--
-- The extra enables its Tailwind integration by default. Keep the list of
-- filetypes explicit so HTML/CSS and all React/Next.js buffers are covered.
return {
  {
    "nvim-mini/mini.hipatterns",
    optional = true,
    opts = {
      tailwind = {
        enabled = true,
        ft = {
          "astro",
          "css",
          "html",
          "javascript",
          "javascriptreact",
          "less",
          "scss",
          "svelte",
          "typescript",
          "typescriptreact",
          "vue",
        },
        -- Highlight the whole utility class, not only the color name.
        style = "full",
      },
    },
  },
}

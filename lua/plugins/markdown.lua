-- Markdown preview via markdown-preview.nvim.
--
-- LazyVim's lang.markdown extra ships the plugin with a prebuilt Linux server
-- binary. On this machine that binary segfaults immediately (exit 139), so
-- <leader>cp silently does nothing: the plugin starts it, it dies before it
-- can open a browser, and no error is shown.
--
-- The plugin falls back to `node app/index.js` when the binary is missing, so
-- remove the broken binary during the build and install the server's runtime
-- dependencies instead. Requires `node` and `npm` on PATH at install/update
-- time; the preview itself needs no extra system packages.
return {
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && rm -f bin/markdown-preview-linux && npm install --omit=dev --no-audit --no-fund",
  },
}

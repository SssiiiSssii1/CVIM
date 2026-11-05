-- Formatting for file types that LazyVim's extras don't fully cover.
-- TOML uses the taplo CLI (the LSP formatter currently returns no edits),
-- Dockerfiles use dockerfmt, C/C++ use clang-format, and Rust uses rustfmt.
-- TypeScript/JavaScript/JSX/TSX format through Bun's built-in `bun fmt`
-- (Prettier-compatible, Bun 1.4+); it must be on PATH, not Mason.
-- All other formatters are installed by Mason (rustfmt comes from rustup).
--
-- On Fedora, clang-format can also be installed system-wide with:
--   sudo dnf install -y clang-tools-extra
--
-- LazyVim already owns the single format-on-save hook (the `LazyFormat`
-- augroup on BufWritePre), and conform.nvim is its primary formatter. Do not
-- add another BufWritePre autocmd or set `format_on_save` here: that would
-- format twice. LazyVim's default `lsp_format = "fallback"` means clangd only
-- formats when conform has no formatter, so clang-format and clangd do not
-- conflict.

-- Prefer clang-format from PATH (Mason prepends its bin directory). If the
-- plugin has not updated PATH yet, fall back to Mason's known install path.
local function clang_format_command()
  if vim.fn.exepath("clang-format") ~= "" then
    return "clang-format"
  end
  local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "clang-format")
  if vim.fn.executable(mason) == 1 then
    return mason
  end
  return "clang-format"
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- Bun's built-in formatter for JavaScript/TypeScript. Listed as the
        -- only entry so it fully replaces prettierd/prettier from LazyVim's
        -- prettier extra. `.h`/`.cpp` notes below are unaffected.
        javascript = { "bun-fmt" },
        javascriptreact = { "bun-fmt" },
        typescript = { "bun-fmt" },
        typescriptreact = { "bun-fmt" },
        -- Neovim maps .c/.h to `c` and .cc/.cpp/.hpp to `cpp`; .h can also be
        -- detected as `cpp`. Both filetypes use clang-format.
        c = { "clang-format" },
        cpp = { "clang-format" },
        rust = { "rustfmt" },
        toml = { "taplo" },
        dockerfile = { "dockerfmt" },
      },
      formatters = {
        -- conform pipes the buffer to the command and reads the formatted
        -- result from stdout. --stdin-filepath gives bun the real path so it
        -- picks the parser and reads .prettierrc/bunfig.toml/.editorconfig
        -- (the file itself does not have to exist). --no-script makes
        -- `bun fmt` run the formatter even in a project whose package.json
        -- defines a `fmt` script; without it a project script would run
        -- instead, which is not what an editor should do on save.
        ["bun-fmt"] = {
          command = "bun",
          args = { "fmt", "--no-script", "--stdin-filepath", "$FILENAME" },
          stdin = true,
        },
        ["clang-format"] = {
          command = clang_format_command,
          -- Respect a project's .clang-format/_clang-format when present.
          -- Otherwise use a 4-space, 120-column fallback that matches the
          -- editor indentation for C/C++ and competitive programming.
          args = function(_, ctx)
            local project_style = vim.fs.find({ ".clang-format", "_clang-format" }, {
              path = ctx.dirname,
              upward = true,
            })[1]
            local style = project_style and "file" or "{BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 120}"
            return { "-style=" .. style, "-assume-filename", "$FILENAME" }
          end,
        },
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "clang-format", "dockerfmt" } },
  },
}

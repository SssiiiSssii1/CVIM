-- Formatting for web and non-LazyVim file types.
--
-- Web formatter policy:
--   0. ESLint LSP fixes run first (registered by this file as a LazyVim
--      formatter, priority 200). This is the only step that applies
--      auto-fixable lint problems; it does not format code.
--   1. Biome, when the project has a biome.json/biome.jsonc. The LazyVim
--      biome extra's `biome-check` formatter formats, lints, and organizes
--      imports. `require_cwd` makes it unavailable when no Biome config is
--      found, so a Biome project is never formatted by Prettier too.
--   2. Prettier (Mason CLI) for everything else. It reads the project's
--      .prettierrc/.editorconfig automatically.
--   3. `bun fmt` only as a fallback when Prettier is not installed. It is
--      Prettier-compatible and must be on PATH, not Mason.
-- `stop_after_first` is what prevents a Biome project from also running
-- Prettier.
--
-- TOML uses the taplo CLI (the LSP formatter currently returns no edits),
-- Dockerfiles use dockerfmt, C/C++ use clang-format, and Rust uses rustfmt.
-- All Mason-managed formatters are installed by Mason (rustfmt comes from
-- rustup).
--
-- On Fedora, clang-format can also be installed system-wide with:
--   sudo dnf install -y clang-tools-extra
--
-- LazyVim already owns the single format-on-save hook (the `LazyFormat`
-- augroup on BufWritePre), and conform.nvim is its primary formatter. Do not
-- add another BufWritePre autocmd or set `format_on_save` here: that would
-- format twice. LazyVim's default `lsp_format = "fallback"` means clangd only
-- formats when conform has no formatter, so clang-format and clangd do not
-- conflict. The same fallback keeps cssls/html from competing with Prettier.

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
    "neovim/nvim-lspconfig",
    -- LazyVim's own ESLint formatter goes through conform, and conform's
    -- `lsp_format = "fallback"` skips it whenever Prettier/Biome is available.
    -- Run the ESLint LSP formatter directly instead, before conform runs, so
    -- `eslint --fix` code actions apply and Prettier/Biome still formats after.
    -- `lazyvim_eslint_auto_format = false` in config/options.lua prevents the
    -- original formatter from being registered twice.
    init = function()
      LazyVim.format.register({
        name = "eslint: lsp",
        primary = false,
        priority = 200,
        sources = function(buf)
          local clients = vim.lsp.get_clients({
            bufnr = buf,
            name = "eslint",
            method = "textDocument/formatting",
          })
          return vim.tbl_map(function(client)
            return client.name
          end, clients)
        end,
        format = function(buf)
          vim.lsp.buf.format({
            bufnr = buf,
            filter = function(client)
              return client.name == "eslint"
            end,
            timeout_ms = 10000,
          })
        end,
      })
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.eslint = vim.tbl_deep_extend("force", opts.servers.eslint or {}, {
        -- Keep the server able to answer textDocument/formatting even though
        -- LazyVim's own auto-format layer is disabled.
        settings = { format = true },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- One web formatter per save. biome-check is unavailable without a
        -- Biome config (require_cwd), and prettier is skipped when Biome ran.
        javascript = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        javascriptreact = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        typescript = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        typescriptreact = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        css = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        scss = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        less = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        json = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        jsonc = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        graphql = { "biome-check", "prettier", "bun-fmt", stop_after_first = true },
        -- Biome does not support HTML yet, so Prettier is the only option.
        html = { "prettier", "bun-fmt", stop_after_first = true },
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
    -- `biome` supplies both the LSP (`biome lsp-proxy`) and the biome-check
    -- CLI. Prettier is installed by LazyVim's prettier extra.
    opts = { ensure_installed = { "biome", "clang-format", "dockerfmt" } },
  },
}

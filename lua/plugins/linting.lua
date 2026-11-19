-- oxlint for JavaScript/TypeScript.
--
-- LazyVim's linting.eslint extra starts ESLint only where the project has an
-- ESLint config. The NestJS app on this machine lints with oxlint instead
-- (`bun run lint` runs `oxlint --type-aware src/ test/`), so register
-- oxlint with nvim-lint, which already ships an `oxlint` linter that parses
-- oxlint's `--format github` output.
--
-- The condition keeps oxlint off projects that do not have it installed and
-- leaves ESLint available for repositories that use it.
local function oxlint_bin(filename)
  -- Walk up from the buffer so monorepo packages use the workspace binary,
  -- and stop at the first node_modules/.bin/oxlint found.
  local dir = filename ~= "" and vim.fs.dirname(filename) or nil
  while dir do
    local candidate = vim.fs.joinpath(dir, "node_modules", ".bin", "oxlint")
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
    local parent = vim.fs.dirname(dir)
    if parent == dir then
      break
    end
    dir = parent
  end

  local global = vim.fn.exepath("oxlint")
  if global ~= "" then
    return global
  end
end

return {
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters_by_ft = {
        javascript = { "oxlint" },
        javascriptreact = { "oxlint" },
        typescript = { "oxlint" },
        typescriptreact = { "oxlint" },
      },
      linters = {
        oxlint = {
          condition = function(ctx)
            return oxlint_bin(ctx.filename) ~= nil
          end,
          -- Resolve the binary from the buffer's own project instead of
          -- Neovim's working directory, so a file opened from another
          -- project still uses that project's pinned oxlint version.
          cmd = function()
            return oxlint_bin(vim.api.nvim_buf_get_name(0)) or "oxlint"
          end,
        },
      },
    },
  },
}

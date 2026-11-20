-- Formatting: conform.nvim is the only formatter.
-- It runs format-on-save with LSP formatting only as a fallback, so a file is
-- never formatted by both conform and an LSP server on the same save.

local function executable(name)
  return function()
    if vim.fn.exepath(name) ~= "" then
      return true
    end
    local mason = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", name)
    return vim.fn.executable(mason) == 1
  end
end

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

local web_formatters = { "biome-check", "prettier", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = "fallback",
      },
      formatters_by_ft = {
        javascript = web_formatters,
        javascriptreact = web_formatters,
        typescript = web_formatters,
        typescriptreact = web_formatters,
        css = web_formatters,
        scss = web_formatters,
        less = web_formatters,
        json = web_formatters,
        jsonc = web_formatters,
        graphql = web_formatters,
        html = { "prettier", stop_after_first = true },
        markdown = { "prettier", stop_after_first = true },
        yaml = { "prettier", stop_after_first = true },
        toml = { "taplo", stop_after_first = true },
        go = { "gofmt" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        lua = { "stylua", stop_after_first = true },
        sh = { "shfmt", stop_after_first = true },
        bash = { "shfmt", stop_after_first = true },
      },
      formatters = {
        gofmt = { condition = executable("gofmt") },
        rustfmt = { condition = executable("rustfmt") },
        stylua = { condition = executable("stylua") },
        shfmt = { condition = executable("shfmt") },
        taplo = { condition = executable("taplo") },
        prettier = {
          condition = function(_, ctx)
            local bin = vim.fs.joinpath(ctx.dirname or vim.fn.getcwd(), "node_modules", ".bin", "prettier")
            return vim.fn.executable(bin) == 1
              or vim.fn.exepath("prettier") ~= ""
              or vim.fn.executable(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "prettier")) == 1
          end,
        },
        ["biome-check"] = {
          command = "biome",
          args = { "check", "--write", "--stdin-file-path", "$FILENAME" },
          stdin = true,
          condition = function(_, ctx)
            local has_config = #vim.fs.find({ "biome.json", "biome.jsonc" }, {
              path = ctx.dirname or vim.fn.getcwd(),
              upward = true,
            }) > 0
            if not has_config then
              return false
            end
            local bin = vim.fs.joinpath(ctx.dirname or vim.fn.getcwd(), "node_modules", ".bin", "biome")
            return vim.fn.executable(bin) == 1
              or vim.fn.exepath("biome") ~= ""
              or vim.fn.executable(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "biome")) == 1
          end,
        },
        ["clang-format"] = {
          command = clang_format_command,
          args = function(_, ctx)
            local project_style = vim.fs.find({ ".clang-format", "_clang-format" }, {
              path = ctx.dirname or vim.fn.getcwd(),
              upward = true,
            })[1]
            local style = project_style and "file" or "{BasedOnStyle: LLVM, IndentWidth: 4, ColumnLimit: 120}"
            return { "-style=" .. style, "-assume-filename", "$FILENAME" }
          end,
          condition = function()
            return vim.fn.exepath("clang-format") ~= ""
              or vim.fn.executable(vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin", "clang-format")) == 1
          end,
        },
      },
    },
  },
}

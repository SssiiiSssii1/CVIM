-- SQL support on top of LazyVim's lang.sql extra.
--
-- LazyVim configures sqlfluff for both formatting and linting, but its
-- formatter only runs inside a project with a .sqlfluff/pyproject.toml/etc.
-- file, and its linter does not pass a dialect. This module fixes both while
-- still letting a project's own sqlfluff config win.
--
-- Set `vim.g.sql_dialect` (for example "postgres" or "mysql") if your scratch
-- queries use a dialect other than ANSI SQL.
local sqlfluff_config_files = {
  ".sqlfluff",
  "pyproject.toml",
  "setup.cfg",
  "tox.ini",
  "pep8.ini",
}

local function has_project_config(dir)
  if not dir or dir == "" then
    return false
  end
  return vim.fs.find(sqlfluff_config_files, { path = dir, upward = true })[1] ~= nil
end

local function sql_dialect()
  return vim.g.sql_dialect or "ansi"
end

local function buffer_dir()
  local name = vim.api.nvim_buf_get_name(0)
  return name ~= "" and vim.fn.fnamemodify(name, ":p:h") or vim.fn.getcwd()
end

return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters = {
        sqlfluff = {
          cwd = function(_, ctx)
            return ctx.dirname or vim.fn.getcwd()
          end,
          require_cwd = false,
          args = function(_, ctx)
            local args = { "format" }
            if not has_project_config(ctx.dirname) then
              vim.list_extend(args, { "--dialect=" .. sql_dialect() })
            end
            vim.list_extend(args, { "-" })
            return args
          end,
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = {
      linters = {
        sqlfluff = {
          -- nvim-lint evaluates function arguments at run time. The two
          -- functions below produce either
          --   sqlfluff lint --dialect=ansi --format=json -
          -- for standalone files, or
          --   sqlfluff lint --format=json --nocolor -
          -- when a project config supplies the dialect.
          args = {
            "lint",
            function()
              return has_project_config(buffer_dir()) and "--format=json" or "--dialect=" .. sql_dialect()
            end,
            function()
              return has_project_config(buffer_dir()) and "--nocolor" or "--format=json"
            end,
            "-",
          },
        },
      },
    },
  },
}

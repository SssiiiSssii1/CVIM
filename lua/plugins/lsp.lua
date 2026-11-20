
return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "saghen/blink.cmp",
    },
    config = function()
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      })

      -- Single TypeScript server. These are the ts_ls equivalents of the CVIM
      -- vtsls preferences: prefer path aliases, include package.json sources in
      -- auto-imports, keep alias-style renames, and offer module exports as
      -- completion items. The js/ts key mirrors VS Code's inferred-project
      -- setting so legacy NestJS/TypeORM decorators do not produce false errors
      -- in files outside a tsconfig.
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "non-relative",
              includePackageJsonAutoImports = "on",
              useAliasesForRenames = true,
            },
            suggest = {
              autoImports = true,
              includeCompletionsForModuleExports = true,
            },
          },
          javascript = {
            preferences = {
              importModuleSpecifier = "non-relative",
              includePackageJsonAutoImports = "on",
              useAliasesForRenames = true,
            },
            suggest = {
              autoImports = true,
              includeCompletionsForModuleExports = true,
            },
          },
          ["js/ts"] = {
            implicitProjectConfig = {
              experimentalDecorators = true,
            },
          },
        },
      })

      -- Mason's gopls package currently requires Go >= 1.27, but this
      -- system has Go 1.26. Use the gopls already installed via `go install`.
      local gopls = vim.fn.expand("~/go/bin/gopls")
      if vim.fn.executable(gopls) == 1 then
        vim.lsp.config("gopls", {
          cmd = { gopls },
        })
      end

      vim.lsp.enable({
        "lua_ls",
        "ts_ls",
        "gopls",
        "rust_analyzer",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = function(key, action, desc)
            vim.keymap.set("n", key, action, {
              buffer = args.buf,
              desc = desc,
            })
          end

          map("gd", vim.lsp.buf.definition, "Go to definition")
          map("gr", vim.lsp.buf.references, "Find references")
          map("K", vim.lsp.buf.hover, "Hover documentation")
          map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    -- Load at startup so Mason prepends its bin directory to PATH before
    -- vim.lsp.enable() tries to start the servers it installed.
    lazy = false,
    opts = {},
  },
}

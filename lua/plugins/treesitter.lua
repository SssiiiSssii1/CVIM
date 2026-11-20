return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup()

      -- Keep CVIM's filetype-to-parser aliases after nvim-treesitter loads;
      -- otherwise its own registration can overwrite the startup mapping.
      vim.treesitter.language.register("yaml", "yaml.docker-compose")
      vim.treesitter.language.register("json5", "jsonc")

      require("nvim-treesitter").install({
        "lua",
        "javascript",
        "typescript",
        "tsx",
        "go",
        "rust",
        "json",
        "json5",
        "yaml",
        "toml",
        "html",
        "css",
        "bash",
        "markdown",
        "markdown_inline",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "lua",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "go",
          "rust",
          "json",
          "jsonc",
          "yaml",
          "toml",
          "html",
          "css",
          "sh",
          "bash",
          "markdown",
        },
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },
}

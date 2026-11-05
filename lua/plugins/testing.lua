-- Test runner integration on top of LazyVim's test.core extra.
--
-- Go and Rust adapters are added by LazyVim's lang.go and lang.rust extras.
-- NestJS projects normally use Jest, so add the Jest adapter here. It only
-- activates for files that actually belong to a project with Jest installed.
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          env = { CI = "true" },
        })
      )
    end,
  },
}

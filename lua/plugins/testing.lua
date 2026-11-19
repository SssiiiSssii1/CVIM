-- Test runner integration on top of LazyVim's test.core extra.
--
-- Go and Rust adapters are added by LazyVim's lang.go and lang.rust extras.
-- Two JavaScript adapters are registered here because the projects on this
-- machine use both runners:
--   * Vitest is the runner in the NestJS app (vitest.config.ts, `vitest` in
--     package.json). Without this adapter `Space tr` finds no tests there.
--   * Jest covers older Node projects.
-- Each adapter only claims a file when the nearest package.json lists its
-- runner, so they can coexist without double-running tests.
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = {
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      table.insert(
        opts.adapters,
        require("neotest-jest")({
          env = { CI = "true" },
        })
      )
      -- Named adapters are loaded by LazyVim's neotest setup on demand.
      opts.adapters["neotest-vitest"] = {
        env = { CI = "true" },
      }
    end,
  },
}

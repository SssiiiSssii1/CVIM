-- Next.js debugging.
--
-- LazyVim's lang.typescript extra already registers the js-debug-adapter
-- (pwa-node / pwa-chrome) and generic "Launch file"/"Attach" configurations.
-- These entries are appended, not replacements, so plain Node/TS debugging
-- keeps working.
--
-- Server-side: starts `next dev` under js-debug, so breakpoints in Server
-- Components, route handlers, server actions, and proxy.ts are mapped through
-- the server source maps.
-- Client-side: launches Chrome against the dev server. Requires a Chrome or
-- Chromium binary that js-debug can launch (not Firefox).
-- Attach: use this when `next dev` is already running outside Neovim.
local next_configs = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Next.js: server-side",
    runtimeExecutable = "npm",
    runtimeArgs = { "run", "dev" },
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    internalConsoleOptions = "neverOpen",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**", "node_modules/**" },
    resolveSourceMapLocations = {
      "${workspaceFolder}/**",
      "!**/node_modules/**",
    },
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Next.js: attach to server",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**", "node_modules/**" },
    resolveSourceMapLocations = {
      "${workspaceFolder}/**",
      "!**/node_modules/**",
    },
  },
  {
    type = "pwa-chrome",
    request = "launch",
    name = "Next.js: client-side (Chrome)",
    url = "http://localhost:3000",
    webRoot = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**", "node_modules/**" },
  },
}

local function append_next_configs(configs)
  configs = configs or {}
  local present = {}
  for _, config in ipairs(configs) do
    present[config.name] = true
  end
  for _, config in ipairs(next_configs) do
    if not present[config.name] then
      table.insert(configs, config)
    end
  end
  return configs
end

return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    opts = function(_, opts)
      -- LazyVim's typescript extra creates the per-filetype lists. Append
      -- after it so both the generic and Next.js entries are available.
      local dap = require("dap")
      dap.configurations = dap.configurations or {}
      for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact" }) do
        dap.configurations[ft] = append_next_configs(dap.configurations[ft])
      end
      return opts
    end,
  },
}

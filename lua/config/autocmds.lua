-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Docker Compose files are YAML, but the Compose language server only starts
-- for the `yaml.docker-compose` filetype.
vim.api.nvim_create_autocmd("FileType", {
  pattern = "yaml",
  callback = function()
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
    if name:match("^docker%-compose.*%.ya?ml$") or name:match("^compose.*%.ya?ml$") then
      vim.bo.filetype = "yaml.docker-compose"
    end
  end,
})

-- Reuse the YAML Treesitter parser for the Compose subtype.
vim.treesitter.language.register("yaml", "yaml.docker-compose")

-- Keep editor indentation aligned with each ecosystem's formatter:
--   Go uses tabs with a 4-column display width.
--   Rust and C/C++ use 4 spaces.
-- TypeScript/JavaScript, Lua, JSON, YAML, TOML, Markdown, and shell keep
-- LazyVim's 2-space defaults.
local function set_indent(width, use_tabs)
  vim.bo.expandtab = not use_tabs
  vim.bo.tabstop = width
  vim.bo.shiftwidth = width
  vim.bo.softtabstop = use_tabs and 0 or width
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "go", "gomod", "gowork", "gotmpl" },
  callback = function()
    set_indent(4, true)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "objc", "objcpp", "rust" },
  callback = function()
    set_indent(4, false)
  end,
})

-- Reload vtsls projects when a package is installed outside Neovim.
--
-- vtsls/tsserver caches module resolution for the lifetime of the server, and
-- Neovim on Linux does not advertise workspace/didChangeWatchedFiles (only
-- macOS and Windows do), so `npm install` never invalidates that cache. The
-- new package stays invisible to completion and auto-import until the server
-- re-resolves it. Poll the dependency files with stat() and ask vtsls to run
-- its `typescript.reloadProjects` command a couple of seconds after the last
-- change; that re-resolves node_modules without restarting the server (and
-- keeps the auto-import index warm). Lockfiles and node_modules metadata are
-- watched directly; package.json is compared by dependency signature so
-- editing scripts or the version does not trigger a reload.
local ts_watch = {
  timer = nil,
  snapshots = {},
  last_change = 0,
}

local ts_watch_files = {
  "package-lock.json",
  "pnpm-lock.yaml",
  "yarn.lock",
  "bun.lock",
  "bun.lockb",
  "node_modules/.package-lock.json",
  "node_modules/.modules.yaml",
  "node_modules/.yarn-state.yml",
  "node_modules/.yarn-integrity",
}

local function ts_mtime(path)
  local stat = vim.uv.fs_stat(path)
  if not stat then
    return nil
  end
  return stat.mtime.sec * 1000000000 + (stat.mtime.nsec or 0)
end

local function ts_vtsls_roots()
  local roots = {}
  for _, client in ipairs(vim.lsp.get_clients({ name = "vtsls" })) do
    local root = client.root_dir
    if not root and client.workspace_folders and client.workspace_folders[1] then
      root = vim.uri_to_fname(client.workspace_folders[1].uri)
    end
    if root then
      roots[root] = true
    end
  end
  return roots
end

local function ts_dependency_signature(root)
  local ok, lines = pcall(vim.fn.readfile, root .. "/package.json")
  if not ok then
    return nil
  end

  local decoded, pkg = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(pkg) ~= "table" then
    return nil
  end

  local deps = {}
  for _, field in ipairs({
    "dependencies",
    "devDependencies",
    "optionalDependencies",
    "peerDependencies",
  }) do
    if type(pkg[field]) == "table" then
      for name, version in pairs(pkg[field]) do
        deps[#deps + 1] = ("%s:%s@%s"):format(field, name, tostring(version))
      end
    end
  end
  table.sort(deps)
  return table.concat(deps, "\n")
end

local function ts_snapshot(root)
  local snap = {
    deps = ts_dependency_signature(root),
    mtimes = {},
  }
  for _, rel in ipairs(ts_watch_files) do
    local path = root .. "/" .. rel
    snap.mtimes[path] = ts_mtime(path)
  end
  snap.mtimes[root .. "/node_modules"] = ts_mtime(root .. "/node_modules")
  return snap
end

local function ts_snapshot_changed(before, after)
  if before.deps ~= after.deps then
    return true
  end
  for path, mtime in pairs(after.mtimes) do
    if before.mtimes[path] ~= mtime then
      return true
    end
  end
  return false
end

local function ts_reload_projects()
  local clients = vim.lsp.get_clients({ name = "vtsls" })
  if #clients == 0 then
    return
  end

  for _, client in ipairs(clients) do
    client:request(
      "workspace/executeCommand",
      { command = "typescript.reloadProjects", arguments = {} },
      function(err)
        -- Older vtsls builds may not expose the command; restart as a fallback.
        if err then
          pcall(vim.cmd, "lsp restart vtsls")
        end
      end,
      0
    )
  end
end

local function ts_start_watch()
  if ts_watch.timer then
    return
  end

  for root in pairs(ts_vtsls_roots()) do
    ts_watch.snapshots[root] = ts_snapshot(root)
  end

  ts_watch.timer = assert(vim.uv.new_timer())
  ts_watch.timer:start(
    2000,
    2000,
    vim.schedule_wrap(function()
      local roots = ts_vtsls_roots()
      if next(roots) == nil then
        ts_watch.timer:stop()
        ts_watch.timer:close()
        ts_watch.timer = nil
        ts_watch.snapshots = {}
        ts_watch.last_change = 0
        return
      end

      local now = vim.uv.now()
      for root in pairs(roots) do
        local after = ts_snapshot(root)
        local before = ts_watch.snapshots[root]
        ts_watch.snapshots[root] = after
        if before and ts_snapshot_changed(before, after) then
          ts_watch.last_change = now
        end
      end

      for root in pairs(ts_watch.snapshots) do
        if not roots[root] then
          ts_watch.snapshots[root] = nil
        end
      end

      -- Wait until the install has been quiet for two seconds before reloading.
      if ts_watch.last_change > 0 and now - ts_watch.last_change >= 2000 then
        ts_watch.last_change = 0
        ts_reload_projects()
      end
    end)
  )
end

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "vtsls" then
      ts_start_watch()
    end
  end,
})

-- LspAttach may have fired before this file was loaded.
if next(ts_vtsls_roots()) then
  ts_start_watch()
end

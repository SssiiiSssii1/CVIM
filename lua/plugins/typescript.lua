-- TypeScript/NestJS completion and auto-import tuning.
--
-- LazyVim already provides vtsls, blink.cmp, and the TypeScript keymaps
-- (<leader>co organize imports, <leader>cM add missing imports, <leader>cD
-- fix all). LazyVim also enables workspace TypeScript, auto-imports,
-- completeFunctionCalls, and server-side fuzzy matching.
--
-- The vtsls settings changed here are the module specifier style and the
-- decorator mode used for files outside a tsconfig:
--
--   * importModuleSpecifier = "non-relative" prefers tsconfig "paths" aliases
--     (for example "@/entities/...") over relative imports. LazyVim's default
--     "shortest" chooses a relative path when it is shorter, which ignores the
--     project's alias convention.
--   * js/ts.implicitProjectConfig.experimentalDecorators keeps legacy
--     decorators working in tsserver's "inferred project" (the fallback used
--     for files that no tsconfig.json/jsconfig.json covers). The project uses
--     experimentalDecorators/emitDecoratorMetadata; without this, standalone
--     NestJS/TypeORM files are parsed with standard decorators and report false
--     TS1240 errors. Real tsconfig.json options still take precedence.
--
-- Auto-import workaround for slow project indexes:
-- tsserver builds its auto-import provider lazily on the first completion
-- request. On this project (an NTFS mount) that takes ~10-40 seconds. Before
-- it is ready, vtsls returns a large completion list without auto-import
-- items and marks it complete. blink.cmp caches that response and reuses it
-- while the user keeps typing, so symbols such as typeorm's Entity never
-- appear. The code below:
--   1. bypasses blink's LSP response cache for vtsls until a response really
--      contains an auto-import item, and marks pre-ready responses incomplete;
--   2. warms the provider up after the first completion response and refreshes
--      an open completion menu once it is ready. Starting after that response
--      avoids racing the first completion request, which can otherwise return
--      a partially built list.
-- This is limited to vtsls and guarded so a future blink.cmp API change
-- disables the workaround instead of breaking completion. Remove it if
-- blink/vtsls gain a native way to mark these responses incomplete without
-- trimming the completion list.

local function has_auto_import(items)
  for _, item in ipairs(items or {}) do
    if
      (item.labelDetails and type(item.labelDetails.description) == "string")
      or (type(item.detail) == "string" and item.detail:match("^Add import from"))
    then
      return true
    end
  end
  return false
end

local function buffer_for_client(client)
  local function attached(buf)
    for _, c in ipairs(vim.lsp.get_clients({ bufnr = buf })) do
      if c.id == client.id then
        return true
      end
    end
    return false
  end

  local current = vim.api.nvim_get_current_buf()
  if vim.api.nvim_buf_is_valid(current) and attached(current) then
    return current
  end

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.api.nvim_buf_get_name(buf) ~= "" and attached(buf) then
      return buf
    end
  end
end

local function probe_auto_imports(client)
  if client._auto_imports_ready or client._auto_imports_probing then
    return
  end
  client._auto_imports_probing = true

  local attempts = 0
  local function finish()
    client._auto_imports_probing = false
  end

  local function probe()
    if client:is_stopped() or client._auto_imports_ready then
      finish()
      return
    end

    local bufnr = buffer_for_client(client)
    if not bufnr then
      finish()
      return
    end

    attempts = attempts + 1
    if attempts > 30 then
      -- Stop polling after ~60 seconds. The cache.set hook below still marks
      -- the client ready when a later completion response contains an
      -- auto-import item, so forward typing cannot get stuck on the early list.
      finish()
      return
    end

    local line, character = 0, 0
    local win = vim.fn.bufwinid(bufnr)
    if win ~= -1 then
      local cursor = vim.api.nvim_win_get_cursor(win)
      line = cursor[1] - 1
      local text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
      local byte_col = cursor[2]
      if byte_col == 0 then
        local start = text:find("[%a_$]")
        if start then
          byte_col = start - 1 + math.min(3, #text - (start - 1))
        end
      end
      character = vim.str_utfindex(text, "utf-16", byte_col)
    else
      local last = math.min(50, vim.api.nvim_buf_line_count(bufnr))
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, last, false)
      for i, text in ipairs(lines) do
        local start = text:find("[%a_$]")
        if start then
          line = i - 1
          local byte_col = start - 1 + math.min(3, #text - (start - 1))
          character = vim.str_utfindex(text, "utf-16", byte_col)
          break
        end
      end
    end

    client:request("textDocument/completion", {
      textDocument = { uri = vim.uri_from_bufnr(bufnr) },
      position = { line = line, character = character },
      context = { triggerKind = 1 },
    }, function(err, result)
      if err or not result then
        vim.defer_fn(probe, 2000)
        return
      end

      if not has_auto_import(result.items or result) then
        vim.defer_fn(probe, 2000)
        return
      end

      client._auto_imports_ready = true
      pcall(function()
        require("blink.cmp.sources.lsp.cache").entries[client.id] = nil
      end)

      -- Refresh an open menu at the end of the identifier being typed. The
      -- public blink.cmp API only re-shows an open menu when providers are
      -- specified.
      if vim.api.nvim_get_mode().mode:sub(1, 1) == "i" and vim.api.nvim_get_current_buf() == bufnr then
        local cursor = vim.api.nvim_win_get_cursor(0)
        local before = vim.api.nvim_get_current_line():sub(1, cursor[2])
        if before:match("[%a_$][%w_$]*$") then
          local ok, cmp = pcall(require, "blink.cmp")
          if ok and type(cmp.is_menu_visible) == "function" then
            -- Only refresh a menu that is still open; never reopen one the
            -- user dismissed while the index was building.
            local visible_ok, visible = pcall(cmp.is_menu_visible)
            if visible_ok and visible then
              pcall(cmp.show, { providers = { "lsp" } })
            end
          end
        end
      end
      finish()
    end, bufnr)
  end

  vim.schedule(probe)
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              preferences = {
                importModuleSpecifier = "non-relative",
              },
            },
            -- Files that are not covered by a tsconfig.json/jsconfig.json are
            -- analyzed by tsserver's "inferred project". That project defaults
            -- to standard (TC39) decorators, so legacy decorators from
            -- NestJS/TypeORM (the project sets experimentalDecorators and
            -- emitDecoratorMetadata) are misread and produce false TS1240
            -- errors. Mirror the project's decorator mode for inferred
            -- projects only; a real tsconfig.json always takes precedence.
            -- This does not change strictness or hide any type errors.
            ["js/ts"] = {
              implicitProjectConfig = {
                experimentalDecorators = true,
              },
            },
          },
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      local ok, cache = pcall(require, "blink.cmp.sources.lsp.cache")
      if
        ok
        and type(cache.get) == "function"
        and type(cache.set) == "function"
        and type(cache.entries) == "table"
        and not cache._vtsls_cache_patched
      then
        cache._vtsls_cache_patched = true

        local original_get = cache.get
        cache.get = function(context, client)
          if client and client.name == "vtsls" and not client._auto_imports_ready then
            return nil
          end
          return original_get(context, client)
        end

        local original_set = cache.set
        cache.set = function(context, client, response)
          if client and client.name == "vtsls" and response then
            if not client._auto_imports_ready and has_auto_import(response.items) then
              client._auto_imports_ready = true
            end
            if not client._auto_imports_ready then
              response.is_incomplete_forward = true
              -- Start the readiness probe only after a real completion
              -- response. Starting on attach can race the first request and
              -- make vtsls return a partially built auto-import list.
              probe_auto_imports(client)
            end
          end
          return original_set(context, client, response)
        end
      end

      return opts
    end,
  },
}

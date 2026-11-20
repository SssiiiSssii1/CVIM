local M = {}

local augroup = vim.api.nvim_create_augroup("cvim_statusline", { clear = true })

local function palette()
  local ok_colors, colors = pcall(require, "cyberdream.colors")
  if not ok_colors then
    return nil
  end

  local ok_config, cyberdream = pcall(require, "cyberdream.config")
  local options = ok_config and cyberdream.options or {}

  local active = options.variant or "auto"
  local name = active
  if name == "auto" then
    name = vim.o.background == "light" and "light" or "default"
  elseif name == "dark" then
    name = "default"
  end

  local p = vim.deepcopy(colors[name] or colors.default)

  local ok_util, util = pcall(require, "cyberdream.util")
  if ok_util and util.apply_saturation and options.saturation ~= nil then
    p = util.apply_saturation(p, options.saturation)
  end

  local overrides = options.colors or {}
  local general = vim.tbl_deep_extend("keep", {}, overrides)
  for _, key in ipairs({ "dark", "light", "muted", "auto", "default" }) do
    general[key] = nil
  end
  p = vim.tbl_deep_extend("force", p, general)

  local lookup = active == "auto" and vim.o.background or active
  if lookup == "default" or lookup == "dark" then
    lookup = overrides.dark and "dark" or "default"
  end
  p = vim.tbl_deep_extend("force", p, overrides[lookup] or {})

  return p
end

local function hi(name, opts)
  opts.link = ""
  vim.api.nvim_set_hl(0, name, opts)
end

function M.apply_highlights()
  local p = palette()
  if not p then
    hi("StatusLine", { bg = "NONE" })
    hi("StatusLineNC", { bg = "NONE" })
    hi("CvimStatusLineFile", { bg = "NONE" })
    hi("CvimStatusLineMeta", { bg = "NONE" })
    hi("CvimStatusLineClock", { bold = true })
    return
  end

  -- Keep the bar minimal and transparent; emphasize content with foreground
  -- accents and a subtle, distinct clock section on the far right.
  hi("StatusLine", { fg = p.fg, bg = "NONE" })
  hi("StatusLineNC", { fg = p.grey, bg = "NONE" })
  hi("CvimStatusLineFile", { fg = p.fg, bg = "NONE" })
  hi("CvimStatusLineMeta", { fg = p.grey, bg = "NONE" })
  hi("CvimStatusLineSep", { fg = p.bg_highlight, bg = "NONE" })
  hi("CvimStatusLineClock", { fg = p.cyan, bg = p.bg_highlight, bold = true })
end

local function filetype_label()
  local ft = vim.bo.filetype
  if ft == "" then
    return ""
  end
  return ft
end

function M.clock()
  -- os.date uses the system's local timezone.
  return " 󰥔 " .. os.date("%I:%M %p") .. " "
end

function M.render()
  local ft = filetype_label()
  local parts = {
    "%#CvimStatusLineFile#",
    " %f",
    "%m",
    "%=",
    "%#CvimStatusLineMeta#",
  }

  if ft ~= "" then
    parts[#parts + 1] = ft .. "  "
  end

  parts[#parts + 1] = "%l:%c  %p%%"
  parts[#parts + 1] = "%#CvimStatusLineClock#"
  parts[#parts + 1] = "%{%v:lua.require'config.statusline'.clock()%}"
  parts[#parts + 1] = "%#StatusLine#"

  return table.concat(parts)
end

function M.setup()
  vim.o.laststatus = 3
  vim.o.statusline = "%!v:lua.require'config.statusline'.render()"

  M.apply_highlights()
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = augroup,
    callback = M.apply_highlights,
  })

  local timer = vim.uv.new_timer()
  if timer then
    timer:start(60000, 60000, vim.schedule_wrap(function()
      if vim.api.nvim_get_mode().mode ~= "c" then
        vim.cmd("redrawstatus")
      end
    end))

    vim.api.nvim_create_autocmd("VimLeavePre", {
      group = augroup,
      callback = function()
        if timer and not timer:is_closing() then
          timer:stop()
          timer:close()
        end
      end,
    })
  end
end

return M

local function cyberdream_palette()
  local colors = require("cyberdream.colors")
  local ok_config, cyberdream = pcall(require, "cyberdream.config")
  local options = ok_config and cyberdream.options or {}

  local active = options.variant or "auto"
  local name = active
  if name == "auto" then
    name = vim.o.background == "light" and "light" or "default"
  elseif name == "dark" then
    name = "default"
  end

  local palette = vim.deepcopy(colors[name] or colors.default)

  local ok_util, util = pcall(require, "cyberdream.util")
  if ok_util and util.apply_saturation and options.saturation ~= nil then
    palette = util.apply_saturation(palette, options.saturation)
  end

  local overrides = options.colors or {}
  local general = vim.tbl_deep_extend("keep", {}, overrides)
  for _, key in ipairs({ "dark", "light", "muted", "auto", "default" }) do
    general[key] = nil
  end
  palette = vim.tbl_deep_extend("force", palette, general)

  local lookup = active == "auto" and vim.o.background or active
  if lookup == "default" or lookup == "dark" then
    lookup = overrides.dark and "dark" or "default"
  end
  palette = vim.tbl_deep_extend("force", palette, overrides[lookup] or {})

  return palette
end

local function set_hl(name, values)
  values.link = ""
  vim.api.nvim_set_hl(0, name, values)
end

local function apply_gutter_highlights()
  local p = cyberdream_palette()

  -- Transparent terminals remove the normal background, so Cyberdream's very
  -- dark default line numbers disappear. Use brighter palette colors while
  -- keeping the gutter transparent like the rest of the theme.
  for _, name in ipairs({ "LineNr", "LineNrAbove", "LineNrBelow", "SignColumn", "FoldColumn" }) do
    set_hl(name, { fg = p.grey, bg = "NONE" })
  end
  set_hl("CursorLineNr", { fg = p.fg, bg = "NONE" })
end

return {
  {
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
    },
    config = function(_, opts)
      require("cyberdream").setup(opts)
      vim.cmd.colorscheme("cyberdream")
      apply_gutter_highlights()

      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("cyberdream_gutter", { clear = true }),
        pattern = "cyberdream",
        callback = apply_gutter_highlights,
      })
    end,
  },
}

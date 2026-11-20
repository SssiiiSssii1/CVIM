-- Standalone Neovim startup.
--
-- Keep this order:
--   1. options define the leader and editor behavior before anything else;
--   2. autocmds are registered before filetypes are detected;
--   3. competitive commands are initialized;
--   4. lazy.nvim bootstraps and loads plugin specs;
--   5. global keymaps are defined last so plugin-backed actions resolve after
--      lazy.nvim has set up their plugins.

require("config.options")
require("config.autocmds")
require("config.competitive").setup()
require("config.lazy")
require("config.keymaps")

local map = vim.keymap.set

local M = {}

--- Which-key group names. Kept here so all user-facing key organization lives
--- in one file; registered by the which-key plugin config when it loads.
M.groups = {
  ["<leader>f"] = "Find",
  ["<leader>g"] = "Git",
  ["<leader>h"] = "Hunks",
  ["<leader>c"] = "Code",
  ["<leader>r"] = "Refactor / Run",
}

local function snacks()
  local ok, module = pcall(require, "snacks")
  return ok and module or nil
end

local function project_root()
  return vim.fs.root(0, { ".git" }) or vim.fn.getcwd()
end

local function terminal(cwd)
  local s = snacks()
  if s and s.terminal then
    s.terminal(nil, { cwd = cwd })
  end
end

local function explorer()
  local s = snacks()
  if not s or not s.picker or not s.picker.get then
    return nil
  end
  return (s.picker.get({ source = "explorer" }) or {})[1]
end

local function win_id(win)
  if type(win) == "table" and type(win.win) == "number" then
    return win.win
  end
  if type(win) == "number" then
    return win
  end
end

local function valid(win)
  local id = win_id(win)
  return id and vim.api.nvim_win_is_valid(id)
end

local function focus(win)
  local id = win_id(win)
  if id and vim.api.nvim_win_is_valid(id) then
    vim.api.nvim_set_current_win(id)
    return true
  end
  return false
end

function M.focus_explorer()
  local picker = explorer()
  return picker and picker.list and focus(picker.list.win) or false
end

function M.focus_opener()
  local picker = explorer()
  return picker and picker._main and focus(picker._main.win) or false
end

function M.focus_explorer_input()
  local picker = explorer()
  return picker and picker.input and focus(picker.input.win) or false
end

function M.explorer_windows()
  local picker = explorer()
  if not picker then
    return nil
  end
  local current = vim.api.nvim_get_current_win()
  if picker.list and win_id(picker.list.win) == current then
    return picker, "list"
  end
  if picker.input and win_id(picker.input.win) == current then
    return picker, "input"
  end
  return picker, nil
end

local function window_nav(direction)
  return function()
    local _, where = M.explorer_windows()
    if where == nil and direction == "h" and M.focus_explorer() then
      return
    end
    if where and direction == "l" and M.focus_opener() then
      return
    end
    if where == "input" and direction == "j" then
      local picker = explorer()
      if picker and picker.list and focus(picker.list.win) then
        return
      end
    end
    if where == "list" and direction == "k" then
      if M.focus_explorer_input() then
        return
      end
    end
    vim.cmd.wincmd(direction)
  end
end

-- Files, editing and windows ------------------------------------------------
map("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })
-- Neovim 0.12 binds <C-s> to signature help in insert/select mode by default,
-- which shows "No available signature" when the cursor isn't inside a call.
-- Use the familiar Ctrl+S for saving instead (blink.cmp keeps <C-k> for
-- signature help).
map({ "n", "i", "s" }, "<C-s>", "<cmd>write<cr>", { desc = "Save file" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Close window" })
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

map("n", "<M-w>", "<cmd>close<cr>", { desc = "Close window" })
map("t", "<M-w>", function()
  vim.cmd.stopinsert()
  vim.cmd.close()
end, { desc = "Close terminal window" })

map("n", "<C-/>", function()
  terminal(project_root())
end, { desc = "Toggle terminal at project root" })
map("n", "<C-_>", function()
  terminal(project_root())
end, { desc = "Toggle terminal at project root (alternate key)" })

map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Split window vertically" })
map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Split window horizontally" })

map("n", "<C-h>", window_nav("h"), { desc = "Window left / focus Explorer" })
map("n", "<C-j>", window_nav("j"), { desc = "Window down / Explorer list" })
map("n", "<C-k>", window_nav("k"), { desc = "Window up / Explorer input" })
map("n", "<C-l>", window_nav("l"), { desc = "Window right / return from Explorer" })

map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Close buffer" })

map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Previous search result" })

map("x", ">", ">gv", { desc = "Indent right" })
map("x", "<", "<gv", { desc = "Indent left" })

map("n", "<leader>e", function()
  local s = snacks()
  if s then
    s.explorer()
  end
end, { desc = "Open Explorer" })

-- Snacks Picker -------------------------------------------------------------
local function picker(name)
  return function()
    local s = snacks()
    if s and s.picker and s.picker[name] then
      s.picker[name]()
    end
  end
end

map("n", "<leader>ff", picker("files"), { desc = "Find files" })
map("n", "<leader>fg", picker("grep"), { desc = "Live grep" })
map("n", "<leader>fb", picker("buffers"), { desc = "Find buffers" })
map("n", "<leader>fh", picker("help"), { desc = "Help tags" })
map("n", "<leader>fr", picker("recent"), { desc = "Recent files" })
map("n", "<C-p>", picker("files"), { desc = "Find files (quick)" })
map("n", "<leader>p", picker("commands"), { desc = "Command palette" })
map("n", "<leader>ft", function()
  terminal(project_root())
end, { desc = "Open terminal at project root" })
map("n", "<leader>fT", function()
  terminal(vim.fn.getcwd())
end, { desc = "Open terminal in current directory" })

-- Git -----------------------------------------------------------------------
map("n", "<leader>gg", function()
  local s = snacks()
  if s then
    s.lazygit()
  end
end, { desc = "Open LazyGit" })

map("n", "<leader>gl", function()
  local s = snacks()
  if s then
    s.lazygit.log()
  end
end, { desc = "LazyGit log" })

map("n", "<leader>gL", function()
  local s = snacks()
  if s then
    s.lazygit.log_file()
  end
end, { desc = "LazyGit log for current file" })

local function browse(what)
  return function()
    local s = snacks()
    if s and s.gitbrowse then
      s.gitbrowse({ what = what })
    end
  end
end

map("n", "<leader>gB", browse("file"), { desc = "Browse file on remote" })
map("n", "<leader>gR", browse("repo"), { desc = "Browse repository on remote" })
map("n", "<leader>gO", browse("commit"), { desc = "Browse commit on remote" })
map("n", "<leader>gC", picker("git_branches"), { desc = "Browse/checkout Git branches" })

local function gitsigns(fn, desc, mode)
  map(mode or "n", "<leader>h" .. fn.key, function()
    local ok, gs = pcall(require, "gitsigns")
    if ok then
      gs[fn.name]()
    end
  end, { desc = desc })
end

gitsigns({ key = "s", name = "stage_hunk" }, "Stage hunk")
map("x", "<leader>hs", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    gs.stage_hunk()
  end
end, { desc = "Stage selected lines" })
gitsigns({ key = "u", name = "unstage_hunk" }, "Unstage hunk")
gitsigns({ key = "r", name = "reset_hunk" }, "Reset hunk")
gitsigns({ key = "p", name = "preview_hunk" }, "Preview hunk")

map("n", "[c", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    gs.prev_hunk()
  end
end, { desc = "Previous Git hunk" })

map("n", "]c", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    gs.next_hunk()
  end
end, { desc = "Next Git hunk" })

map("n", "<leader>gb", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    gs.blame_line()
  end
end, { desc = "Git blame current line" })

map("n", "<leader>gd", function()
  local ok, gs = pcall(require, "gitsigns")
  if ok then
    gs.diffthis()
  end
end, { desc = "Show full-file Git diff" })

-- Flash ---------------------------------------------------------------------
map("n", "<leader>s", function()
  local ok, flash = pcall(require, "flash")
  if ok then
    flash.jump()
  end
end, { desc = "Flash jump" })

map("n", "<leader>S", function()
  local ok, flash = pcall(require, "flash")
  if ok then
    flash.treesitter()
  end
end, { desc = "Flash treesitter jump" })

-- Competitive programming ---------------------------------------------------
map("n", "<leader>rN", function()
  local ok, cp = pcall(require, "config.competitive")
  if ok then
    cp.new_prompt()
  end
end, { desc = "CP: New C++ solution" })

function M.register_groups()
  local specs = {}
  for prefix, name in pairs(M.groups) do
    specs[#specs + 1] = { prefix, group = name }
  end
  require("which-key").add(specs)
end

return M

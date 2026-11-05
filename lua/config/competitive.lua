-- Lightweight C++ competitive-programming workflow.
--
-- This is deliberately not a plugin. It adds five commands and a handful of
-- buffer-local keymaps only for C++ buffers, so the normal IDE workflow is
-- untouched.
--
--   :CPNew [name]  create a new solution (default: main.cpp)
--   :CPInit        create input.txt and expected.txt next to the solution
--   :CPBuild       compile the current file with g++
--   :CPRun         compile and run in a terminal (uses input.txt if present)
--   :CPTest        run against input.txt and compare with expected.txt
--
-- Binaries are written to .cp-build/ next to the source file.

local M = {}

local function current_dir()
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    return vim.fn.fnamemodify(file, ":p:h")
  end
  return vim.fn.getcwd()
end

local function current_paths()
  local src = vim.api.nvim_buf_get_name(0)
  local dir = current_dir()
  local base = src ~= "" and vim.fn.fnamemodify(src, ":t:r") or "main"
  local build = vim.fs.joinpath(dir, ".cp-build")
  return dir, build, vim.fs.joinpath(build, base)
end

local function is_cpp()
  return vim.bo.filetype == "cpp"
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Competitive Programming" })
end

local function open_terminal(cmd, cwd)
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.terminal then
    -- interactive = false keeps the terminal open after the program exits and
    -- avoids dropping the user into insert mode just to read the output.
    snacks.terminal({ "bash", "-lc", cmd }, { cwd = cwd, interactive = false })
    return
  end

  vim.cmd("botright split")
  vim.cmd("terminal " .. vim.fn.shellescape("bash") .. " -lc " .. vim.fn.shellescape(cmd))
end

---@param name? string
function M.new(name)
  name = (name or "main"):gsub("%.cpp$", "")
  if name == "" then
    name = "main"
  end

  local path = vim.fs.joinpath(current_dir(), name .. ".cpp")
  if vim.fn.filereadable(path) == 1 then
    vim.cmd.edit(vim.fn.fnameescape(path))
    return
  end

  local template = {
    "#include <bits/stdc++.h>",
    "",
    "using namespace std;",
    "",
    "using ll = long long;",
    "",
    "int main() {",
    "    ios::sync_with_stdio(false);",
    "    cin.tie(nullptr);",
    "",
    "    return 0;",
    "}",
    "",
  }

  vim.fn.writefile(template, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  notify("created " .. path)
end

function M.new_prompt()
  vim.ui.input({ prompt = "CP file name: ", default = "main" }, function(input)
    if input and input ~= "" then
      M.new(input)
    end
  end)
end

function M.init()
  local dir = current_dir()
  for _, name in ipairs({ "input.txt", "expected.txt" }) do
    local path = vim.fs.joinpath(dir, name)
    if vim.fn.filereadable(path) == 0 then
      vim.fn.writefile({}, path)
    end
  end
  notify("input.txt and expected.txt ready in " .. dir)
end

---@return string? binary, string? dir
function M.build()
  if not is_cpp() then
    notify("open a C++ file first", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("g++") ~= 1 then
    notify("g++ was not found in PATH", vim.log.levels.ERROR)
    return
  end

  if vim.bo.modified then
    vim.cmd.write()
  end

  local src = vim.api.nvim_buf_get_name(0)
  if src == "" or vim.fn.filereadable(src) == 0 then
    notify("save the C++ file first", vim.log.levels.WARN)
    return
  end

  local dir, build_dir, bin = current_paths()
  vim.fn.mkdir(build_dir, "p")

  local result = vim
    .system({
      "g++",
      "-std=c++20",
      "-O2",
      "-Wall",
      "-Wextra",
      "-Wshadow",
      "-DLOCAL",
      src,
      "-o",
      bin,
    }, { cwd = dir, text = true })
    :wait()

  if result.code ~= 0 then
    local lines = vim.split((result.stderr or "") .. (result.stdout or ""), "\n", { trimempty = true })
    vim.fn.setqflist({}, "r", {
      title = "CP Build",
      lines = lines,
      efm = "%f:%l:%c: %m",
    })
    vim.cmd("copen")
    notify("build failed", vim.log.levels.ERROR)
    return
  end

  pcall(vim.cmd, "cclose")
  vim.fn.setqflist({}, "r", { title = "CP Build", lines = {} })
  notify("built " .. vim.fn.fnamemodify(bin, ":t"))
  return bin, dir
end

function M.run()
  local bin, dir = M.build()
  if not bin then
    return
  end

  local input = vim.fs.joinpath(dir, "input.txt")
  local cmd = vim.fn.shellescape(bin)
  if vim.fn.filereadable(input) == 1 then
    cmd = cmd .. " < " .. vim.fn.shellescape(input)
  end

  open_terminal(cmd, dir)
end

function M.test()
  local bin, dir = M.build()
  if not bin then
    return
  end

  local input = vim.fs.joinpath(dir, "input.txt")
  if vim.fn.filereadable(input) == 0 then
    notify("create input.txt with :CPInit", vim.log.levels.WARN)
    return
  end

  local cmd = vim.fn.shellescape(bin) .. " < " .. vim.fn.shellescape(input)
  local result = vim.system({ "bash", "-lc", cmd }, { cwd = dir, text = true }):wait()
  local stdout = result.stdout or ""
  local stderr = result.stderr or ""

  local expected_path = vim.fs.joinpath(dir, "expected.txt")
  local has_expected = vim.fn.filereadable(expected_path) == 1
  local expected = has_expected and table.concat(vim.fn.readfile(expected_path), "\n") or ""

  local function normalize(value)
    return (value:gsub("\r\n", "\n"):gsub("%s+$", ""))
  end

  local passed = has_expected and normalize(stdout) == normalize(expected) or nil
  local verdict = passed == nil and "**output only**" or (passed and "**PASS**" or "**FAIL**")

  local lines = {
    "# CP Test",
    "",
    "- Exit code: `" .. tostring(result.code) .. "`",
    "- Verdict: " .. verdict,
    "",
    "## Output",
    "```text",
    stdout:gsub("\n$", ""),
    "```",
  }

  if stderr ~= "" then
    vim.list_extend(lines, { "", "## Stderr", "```text", stderr:gsub("\n$", ""), "```" })
  end

  if has_expected and not passed then
    vim.list_extend(lines, { "", "## Expected", "```text", expected:gsub("\n$", ""), "```" })
  end

  vim.cmd("botright split")
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].modifiable = false
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close CP Test" })
  vim.api.nvim_win_set_buf(0, buf)

  notify(
    "test " .. (passed == nil and "ran" or (passed and "passed" or "failed")),
    passed == false and vim.log.levels.ERROR or vim.log.levels.INFO
  )
end

function M.setup()
  if M._did_setup then
    return
  end
  M._did_setup = true

  vim.api.nvim_create_user_command("CPNew", function(opts)
    M.new(opts.args)
  end, { nargs = "?", desc = "CP: create a new C++ solution" })

  vim.api.nvim_create_user_command("CPInit", M.init, { desc = "CP: create input.txt and expected.txt" })
  vim.api.nvim_create_user_command("CPBuild", M.build, { desc = "CP: compile the current C++ file" })
  vim.api.nvim_create_user_command("CPRun", M.run, { desc = "CP: compile and run the current C++ file" })
  vim.api.nvim_create_user_command("CPTest", M.test, { desc = "CP: run against input.txt and expected.txt" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "cpp",
    callback = function(args)
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
      end

      map("<leader>rc", M.build, "CP: Compile")
      map("<leader>rr", M.run, "CP: Run")
      map("<leader>rt", M.test, "CP: Test")
      map("<leader>ri", M.init, "CP: Init input/expected")
    end,
  })
end

return M

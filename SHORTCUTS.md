# Neovim / LazyVim Shortcut Sheet

For this configuration. Leader key is `Space`; localleader is `\`.

Tip: press `Space` and pause to see the which-key menu, or `Space sk` to
search every keymap. `Space ?` shows only the keymaps for the current buffer.

## File explorer (snacks)

Open it with `Space e` (project root) or `Space E` (current directory).

| Key | Action |
| --- | --- |
| `Enter` / `l` | Open file or enter directory |
| `h` | Close directory |
| `Backspace` | Go up one directory |
| `.` | Set the explorer's directory to the current one |
| `Tab` | Select (mark) the item; repeat to select more |
| `a` | Add a file or directory (end with `/` for a directory) |
| `d` | Delete (system trash when available) |
| `r` | Rename |
| `c` | Copy |
| `m` | Move |
| `y` | Yank path(s) |
| `p` | Paste (copies) |
| `o` | Open with the system application |
| `u` | Refresh |
| `P` | Toggle preview |
| `H` | Toggle hidden files |
| `I` | Toggle ignored files |
| `Z` | Close all directories |
| `Ctrl+t` | Open a terminal in the current directory |
| `Ctrl+c` | Change the tab's directory to the current one |
| `Space /` | Grep in the current directory |
| `]g` / `[g` | Next / previous Git change |
| `]d` / `[d` | Next / previous diagnostic |
| `]w` / `[w` | Next / previous warning |
| `q` / `Esc` | Close the explorer |
| `?` | Show the explorer's help |

### Move a whole folder

**Select + navigate + move (recommended)**

1. `Space e` to open the explorer.
2. Put the cursor on the folder and press `Tab` to select it.
3. Enter the destination folder (`Enter`) or go up (`Backspace`).
4. Press `m` and confirm `Move <folder> to <directory>?`.

**Direct move/rename**

1. Put the cursor on the folder (no selection) and press `m`.
2. A `New File Name:` prompt opens, prefilled with the folder's path.
3. Edit the path, for example `../other-dir/my-folder`, and press `Enter`.
   Missing parent directories are created automatically.

Notes:

- `m` uses `vim.fn.rename`, so moving across different filesystems/mounts can
  fail. Copy with `c` and delete the original with `d` in that case.
- `p` pastes (copies) files you yanked with `y`; it does not move them.
- LSP rename hooks run as well, so imports may be updated for moved files.

## Files and search (snacks picker)

| Key | Action |
| --- | --- |
| `Space Space` / `Space ff` | Find files (root dir) |
| `Ctrl+p` | Find files (custom shortcut) |
| `Space fF` | Find files (cwd) |
| `Space fg` | Find Git files |
| `Space fr` / `Space fR` | Recent files / recent files (cwd) |
| `Space fp` | Projects |
| `Space fc` | Find config file |
| `Space fb` / `Space fB` | Buffers / all buffers |
| `Space ,` | Buffers |
| `Space /` / `Space sg` | Grep (root dir) |
| `Space sG` | Grep (cwd) |
| `Space sw` / `Space sW` | Search word or visual selection (root / cwd) |
| `Space :` / `Space sc` | Command history |
| `Space sC` / `Space p` | Commands (`Space p` is custom) |
| `Space sh` | Help pages |
| `Space sk` | Search all keymaps |
| `Space sR` | Resume the last picker |
| `Space s/` | Search history |
| `Space s"` | Registers |
| `Space sj` | Jumps |
| `Space sm` | Marks |
| `Space su` | Undo tree |
| `Space sd` / `Space sD` | Diagnostics / buffer diagnostics |
| `Space sb` / `Space sB` | Buffer lines / grep open buffers |
| `Space sa` | Autocmds |
| `Space sH` | Highlights |
| `Space si` | Icons |
| `Space sq` / `Space xl` | Quickfix list |
| `Space sl` / `Space xq` | Location list |
| `Space st` / `Space sT` | Todo / todo, fix, fixme |
| `Space sp` | Search for a plugin spec |
| `Space sn*` | Noice (messages) pickers |
| `Space n` | Notification history |
| `Space un` | Dismiss all notifications |

Within a picker: `Tab` selects the current item and moves down, `?` toggles
help, `q` or `Esc` closes it.

## Buffers

| Key | Action |
| --- | --- |
| `Shift+h` / `Shift+l` | Previous / next buffer |
| `[b` / `]b` | Previous / next buffer |
| `[B` / `]B` | Move current buffer left / right |
| `Space bb` / `Space \`` | Switch to the other buffer |
| `Space bd` | Delete buffer |
| `Space bD` | Delete buffer and window |
| `Space bo` | Delete other buffers |
| `Space bi` | Delete invisible buffers |
| `Space bj` | Pick a buffer |
| `Space bl` / `Space br` | Delete buffers to the left / right |
| `Space bp` / `Space bP` | Toggle pin / delete non-pinned buffers |

## Windows, splits, tabs

| Key | Action |
| --- | --- |
| `Ctrl+h/j/k/l` | Move to left/lower/upper/right window |
| `Ctrl+Up/Down` | Increase / decrease window height |
| `Ctrl+Left/Right` | Decrease / increase window width |
| `Space -` | Split below |
| `Space \|` | Split right |
| `Space wd` | Close window |
| `Space wm` / `Space uZ` | Toggle zoom mode |
| `Space uz` | Toggle zen mode |
| `Space <tab><tab>` | New tab |
| `Space <tab>d` | Close tab |
| `Space <tab>]` / `[` | Next / previous tab |
| `Space <tab>l` / `f` | Last / first tab |
| `Space <tab>o` | Close other tabs |

## Editing

| Key | Action |
| --- | --- |
| `i` / `a` / `o` | Insert before / after / below |
| `Esc` | Normal mode; also clears search highlight |
| `Ctrl+s` | Save file (normal, insert, visual) |
| `u` / `Ctrl+r` | Undo / redo |
| `yy` / `dd` / `p` | Yank line / delete line / paste |
| `gcc` / `gc` | Comment line / selection |
| `gco` / `gcO` | Add comment below / above |
| `Alt+j` / `Alt+k` | Move line or selection down / up |
| `n` / `N` | Next / previous search result |
| `s` / `S` | Flash jump / Flash Treesitter |
| `Ctrl+Space` | Treesitter incremental selection |
| `Space fn` | New file |
| `Space K` | Keywordprg (for example `man`) |
| `Space ur` | Redraw, clear highlight, update diff |

## LSP and code intelligence

| Key | Action |
| --- | --- |
| `gd` / `gD` | Go to definition / declaration |
| `gr` / `gI` / `gy` | References / implementation / type definition |
| `K` / `gK` | Hover / signature help |
| `Ctrl+k` | Signature help (insert mode) |
| `Space ca` | Code action |
| `Space cc` / `Space cC` | Run / refresh codelens |
| `Space cr` | Rename symbol |
| `Space cR` | Rename file |
| `Space cA` | Source action |
| `Space co` | Organize imports |
| `Space cM` | Add missing imports (TypeScript buffer) |
| `Space cD` | Fix all (TypeScript buffer) |
| `]]` / `[[` | Next / previous reference |
| `Alt+n` / `Alt+p` | Next / previous reference |
| `Space ss` / `Space sS` | Document / workspace symbols |
| `Space cl` | LSP information |
| `Space cs` / `Space cS` | Symbols / references trouble view |
| `gai` / `gao` | Incoming / outgoing calls |
| `Space xx` / `Space xX` | Project / buffer diagnostics (Trouble) |
| `Space xL` / `Space xQ` | Location / quickfix list (Trouble) |

## Formatting and diagnostics

| Key | Action |
| --- | --- |
| `Space cf` | Format file or selection |
| `Space cF` | Format injected languages |
| `Space cd` | Line diagnostics |
| `]d` / `[d` | Next / previous diagnostic |
| `]e` / `[e` | Next / previous error |
| `]w` / `[w` | Next / previous warning |
| `Space uf` / `Space uF` | Toggle auto-format globally / for buffer |
| `Space ud` | Toggle diagnostics |

## Git

| Key | Action |
| --- | --- |
| `Space gg` / `Space gG` | Lazygit (root / cwd), if `lazygit` is installed |
| `Space gs` / `Space gS` | Git status / stash |
| `Space gd` / `Space gD` | Diff hunks / diff against origin |
| `Space gl` / `Space gL` | Git log / Git log (cwd) |
| `Space gb` | Blame line |
| `Space gf` | File history |
| `Space gB` / `Space gY` | Browse (open / copy URL) |
| `Space gC` | Browse and checkout a branch (custom) |
| `Space gi` / `Space gI` | GitHub issues (open / all) |
| `Space gp` / `Space gP` | GitHub pull requests (open / all) |
| `Space ghs` / `Space ghr` | Stage / reset hunk |
| `Space ghS` / `Space ghR` | Stage / reset buffer |
| `Space ghu` | Undo stage hunk |
| `Space ghp` | Preview hunk inline |
| `Space ghb` | Blame line (full) |

Changed lines are marked in the sign column. GitHub pickers need a GitHub
remote and `gh` authentication.

## Debugging (nvim-dap)

| Key | Action |
| --- | --- |
| `Space db` | Toggle breakpoint |
| `Space dB` | Conditional breakpoint |
| `Space dc` | Run / continue |
| `Space dC` | Run to cursor |
| `Space dg` | Go to line (no execute) |
| `Space di` / `Space do` / `Space dO` | Step into / out / over |
| `Space dj` / `Space dk` | Down / up the stack |
| `Space dl` | Run last |
| `Space dP` | Pause |
| `Space dr` | Toggle REPL |
| `Space ds` | Session |
| `Space dt` | Terminate |
| `Space dw` | Widgets |
| `Space de` | Evaluate expression (normal / visual) |
| `Space du` | Toggle debugger UI |
| `Space da` | Run with arguments |

Go uses `delve`, TypeScript/JavaScript uses `js-debug-adapter`, Rust/C/C++ use
`codelldb`. LazyVim also reads `.vscode/launch.json`.

## Tests (neotest)

| Key | Action |
| --- | --- |
| `Space tt` | Run current test file |
| `Space tr` | Run nearest test |
| `Space tT` | Run all test files |
| `Space tl` | Run last test |
| `Space ts` / `Space tS` | Toggle summary / stop |
| `Space to` / `Space tO` | Show output / toggle output panel |
| `Space tw` | Toggle watch |
| `Space ta` | Attach to a test |
| `Space td` | Debug nearest test |

## Terminal

| Key | Action |
| --- | --- |
| `Ctrl+/` | Toggle terminal (root dir) |
| `Space ft` | Terminal in project root |
| `Space fT` | Terminal in cwd |

## UI toggles

| Key | Action |
| --- | --- |
| `Space us` | Spelling |
| `Space uw` | Wrap |
| `Space uL` | Relative line numbers |
| `Space ul` | Line numbers |
| `Space uc` | Conceal level |
| `Space uA` | Tabline |
| `Space uT` | Treesitter highlight |
| `Space ub` | Dark background |
| `Space uD` | Dimming |
| `Space ua` | Animations |
| `Space ug` | Indent guides |
| `Space uS` | Smooth scroll |
| `Space uh` | Inlay hints |
| `Space ui` / `Space uI` | Inspect position / syntax tree |
| `Space uC` | Colorschemes |
| `Space un` | Dismiss notifications |

## Sessions and quitting

| Key | Action |
| --- | --- |
| `Space qq` | Quit all |
| `Space qs` | Restore session |
| `Space qS` | Select session |
| `Space ql` | Restore last session |
| `Space qd` | Don't save the current session |

## Plugins, tools, help

| Key | Action |
| --- | --- |
| `Space l` | Open Lazy |
| `Space cm` | Mason |
| `Space D` | Database sidebar (Dadbod UI) |
| `Space L` | LazyVim changelog |
| `Space ?` | Buffer keymaps |
| `Space H` | Beginner guide (custom) |
| `:Lazy` | Plugin manager (`I` install, `U` update, `S` sync) |
| `:LazyExtras` | Enable/disable LazyVim extras |
| `:Mason` | Install LSP servers, formatters, linters |
| `:checkhealth` | Health check |
| `:Tutor` | Interactive Vim tutorial |

## Custom shortcuts in this config

| Key | Action |
| --- | --- |
| `Ctrl+p` | Find files |
| `Space p` | Command palette |
| `Space H` | Open `BEGINNER_GUIDE.md` |
| `Space gC` | Browse and checkout a Git branch |
| `Space rn` | New competitive-programming C++ file |

Competitive programming, C++ buffers only:

| Key | Action |
| --- | --- |
| `Space rc` | Compile current file |
| `Space rr` | Compile and run in a terminal |
| `Space rt` | Run against `input.txt`, compare with `expected.txt` |
| `Space ri` | Create `input.txt` and `expected.txt` |

Commands: `:CPNew [name]`, `:CPInit`, `:CPBuild`, `:CPRun`, `:CPTest`.

Dashboard keys: `f` find file, `g` find text, `r` recent files, `p` projects,
`c` config, `l` Lazy, `t` Vim Tutor, `b` beginner guide, `k` all keymaps,
`q` quit.

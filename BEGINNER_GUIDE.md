# Neovim Beginner Guide

Your **leader key is `Space`**. Press `Space` and pause: the which-key popup
shows every keybinding that can follow. You do not need to memorize everything.

## 1. Open Neovim

- `nvim` opens Neovim and shows the dashboard.
- `nvim .` opens the current directory as a project.
- `nvim ~/projects/myapp` opens a project directory.
- `nvim path/to/file` opens a file.
- Inside Neovim, `:cd ~/projects/myapp` changes the working directory.
- `Space fp` shows recent projects; `Space e` opens the file explorer.

## 2. The three modes you need

- **Normal mode**: press `Esc`. This is where you move, copy, delete, and run
  shortcuts. Neovim starts here.
- **Insert mode**: press `i` to type before the cursor, `a` to type after it,
  or `o` to open a new line below. Press `Esc` when finished typing.
- **Visual mode**: press `v` for characters, `V` for whole lines, or `Ctrl+v`
  `to delete, or`c` to
  change it.
- **Command mode**: press `:` and type a command, then `Enter`.

If you are ever lost, press `Esc` a few times. Then press `Space` to see what
you can do.

## 3. Edit, save, and close files

- `i` enter Insert mode; `Esc` return to Normal mode.
- `<C-s>` save the file. (`:w` also saves.)
- `:wq` save and quit. `:q` quit. `:q!` quit without saving.
- `Space qq` quit all of Neovim.
- `Space bd` close the current buffer without closing Neovim.
- `Shift+h` / `Shift+l` move to the previous / next open file.
- `u` undo; `Ctrl+r` redo.
- `yy` copy a line; `dd` cut a line; `p` paste.
- Select with Visual mode, then `y` copy or `d` delete.
- Neovim uses the system clipboard, so copied text can be pasted in other apps.

## 4. Find files and search text

- `Ctrl+p` or `Space Space` — find files in the project.
- `Space /` or `Space sg` — search text across the project.
- `Space sw` — search for the word under the cursor.
- `Space e` — open/close the file explorer.
- `Space ,` — switch between open buffers.
- `Space fr` — recently opened files.
- `Space p` — command palette (search and run any Neovim command).
- `Space sk` — search all keymaps. `Space ?` — keymaps for the current buffer.
- `Space sh` — search Neovim help pages.
- `/text` — search inside the current file; `n` / `N` jump to next/previous
  match; `Esc` clears the highlight.

### File explorer keys

With the explorer open (`Space e`):

- `Enter` open a file or expand a directory
- `Backspace` go up one directory
- `a` add a file/directory
- `d` delete (moves to trash when available)
- `r` rename
- `y` copy path, `p` paste, `c` copy, `m` move
- `H` show/hide hidden files
- `q` close the explorer

## 5. Code intelligence (LSP)

These work when the language server for the file is installed:

- `gd` — go to definition
- `gr` — find references
- `gI` — go to implementation
- `K` — show hover documentation
- `Space ca` — code actions (fixes, imports, refactors)
- `Space cr` — rename a symbol
- `Space cf` — format the file
- `Space cd` — show diagnostics for the current line
- `]d` / `[d` — next / previous diagnostic
- `Space xx` — all project diagnostics
- `Space ss` — document symbols
- `Space sS` — workspace symbols
- `Space cl` — LSP information for the current buffer
- `Space ch` — switch between a C/C++ source and header

Formatting runs automatically when you save (C/C++, Go, TypeScript/JavaScript,
JSON, YAML, TOML, Rust, Dockerfile, Markdown, SQL, and shell). `Space uf`
toggles auto-format. C/C++ uses `clangd` for code intelligence and
`clang-format` for formatting; a project `.clang-format` file is respected,
otherwise the fallback uses 4 spaces and a 120-column limit. Go uses tabs with
a 4-column width, Rust and C/C++ use 4 spaces, and TypeScript, Lua, JSON, YAML,
TOML, Markdown, and shell keep 2 spaces.

### SQL and databases

- `Space D` or `:DBUI` opens the database sidebar. Use `:DBUIAddConnection`
  to add a connection, or set `vim.g.dbs` in your config.
- `:DB` runs a one-off query through Dadbod.
- SQL is formatted and linted by `sqlfluff`. A project `.sqlfluff`,
  `pyproject.toml`, or similar config is respected. For scratch queries the
  default dialect is ANSI; set `vim.g.sql_dialect = "postgres"` (or `"mysql"`,
  etc.) if your queries use another dialect.
- SQL completion comes from Neovim's SQL syntax plus Dadbod; there is no SQL
  language server in this setup, so completion is lighter than in
  TypeScript/Go/Rust.

### Markdown

- `Space cp` opens a live Markdown preview in your browser.
- `Space um` toggles rendered Markdown inside Neovim.
- `marksman` provides Markdown links/completion, `markdownlint-cli2` reports
  style problems, and `prettier` formats the file.

### Bash and shell scripts

- `bash-language-server` provides completion and diagnostics.
- `shellcheck` diagnostics appear through the Bash language server.
- `shfmt` formats shell scripts on save.

### TypeScript and NestJS

- `vtsls` is the TypeScript language server; `typescript-language-server` is
  intentionally not installed, so there is only one TypeScript server and one
  completion source.
- Completion includes classes, decorators, methods, and symbols from packages
  in `package.json`. Accepting an auto-import item inserts the import
  automatically (for example `Entity` from `typeorm`).
- Decorator completion: type `@Ent`. `@` may first show decorator keywords;
  once you type the name, the menu refreshes with the matching import when the
  auto-import index is ready.
- `Space co` organizes imports: it sorts them and removes unused imports.
  `Space cM` adds missing imports for the symbol under the cursor.
  `Space cD` applies all available fixes for the current file.
- Imports are **not** organized or removed automatically on save. Formatting
  still runs on save, but unused imports stay until you run `Space co`.
- `tsconfig.json` is respected, including `paths` aliases such as `@/...`.
  The TypeScript setting prefers non-relative imports, so an alias is used when
  the project defines one.
- On slow disks or mounted drives, the first auto-import index can take
  10–40 seconds to build. The config starts the readiness probe after the first
  completion response and marks early responses incomplete, so the menu keeps
  asking `vtsls` for fresh results instead of reusing the early list without
  imports. It refreshes an open menu when the index is ready, but does not
  reopen a menu you dismissed.
- If the menu does not refresh by itself, type one more character or press
  `Ctrl-Space` after the `Initializing tsconfig.json` progress message
  disappears; `Entity` then appears with its `typeorm` import. `Space cM` also
  adds the missing import for the symbol under the cursor.
- If completion or auto-import stops working, restart Neovim after changing
  this config, then run `:LspRestart` and check `Space cl` to confirm `vtsls`
  is attached.

### Tests

- `Space tt` runs the current test file; `Space tr` runs the nearest test.
- `Space tT` runs all test files; `Space ts` toggles the test summary.
- `Space to` shows output; `Space tO` toggles the output panel.
- `Space tw` watches the current test file.
- Go and Rust adapters are included. NestJS/Jest projects use the Jest
  adapter automatically once the project has Jest installed locally.
- Tests need the project's own dependencies (`npm install`, `go mod download`,
  etc.) before they can run.

### Debugging (optional)

- `Space db` — toggle a breakpoint
- `Space dc` — start or continue
- `Space di` / `Space do` / `Space dO` — step into / out / over
- `Space du` — toggle the debugger UI
- `Space dt` — stop the debug session
- Go uses `delve`, TypeScript/JavaScript uses `js-debug-adapter`, and Rust/C/C++
  use `codelldb`. These adapters are already installed.
- LazyVim also reads `.vscode/launch.json` when a project provides one.

## 6. Git

- `Space gg` — open lazygit (a full-screen Git UI)
- `Space gs` — Git status picker
- `Space gC` — browse and checkout a Git branch
- `Space gd` — inspect changed hunks
- `Space gl` — Git log
- `Space gb` — blame the current line
- `Space ghp` — preview the hunk under the cursor
- `Space ghs` — stage the hunk
- `Space ghr` — reset the hunk
- Changed lines are marked in the sign column on the left.

## 7. Terminal and windows

- `Ctrl+/` — toggle a terminal (if your terminal passes this key).
- `Space ft` — terminal in the project root.
- `Space fT` — terminal in the current directory.
- `Ctrl+h/j/k/l` — move between windows.
- `Space -` / `Space |` — split below / right.
- `Space wd` — close the current window.

## 8. The 10 shortcuts to learn first

1. `Esc` — return to Normal mode
2. `i` — enter Insert mode
3. `<C-s>` — save
4. `Space Space` — find files
5. `Space /` — search text in the project
6. `Space e` — file explorer
7. `Space ,` — switch buffers
8. `gd` / `gr` — go to definition / find references
9. `Space ca` / `Space cr` — code action / rename
10. `Space cf` / `Space cd` — format / line diagnostics

Bonus: `Space gg` (lazygit), `Ctrl+/` (terminal), `Space qq` (quit all).

## 9. Learning aids

- `:Tutor` — the built-in interactive Vim tutorial (also `t` on the dashboard).
- `Space H` — open this guide.
- `Space` — show the which-key menu.
- Relative line numbers show distance from the cursor. The current line is
  absolute; `5j` moves down five lines.
- `:help` opens Neovim help. `:help key` looks up a topic.
- Press `Space` before a command and read the descriptions; that is the fastest
  way to learn the keymap.

## 10. Competitive programming (C++)

The competitive-programming workflow is deliberately small and only adds
buffer-local shortcuts in C++ files.

- `Space rn` or `:CPNew [name]` creates `main.cpp` (or `name.cpp`) with a
  ready-to-edit template.
- `:CPInit` creates `input.txt` and `expected.txt` next to the source file.
- In a C++ buffer:
  - `Space rc` compiles the current file.
  - `Space rr` compiles and runs it in a terminal, using `input.txt` when it
    exists. The terminal stays open so you can read the output.
  - `Space rt` runs it against `input.txt` and compares the output with
    `expected.txt`.
  - `Space ri` creates `input.txt` and `expected.txt`.
- The same actions are available as `:CPBuild`, `:CPRun`, and `:CPTest`.
- Binaries are written to `.cp-build/` next to the source file, so they do not
  clutter the project root.
- Compile errors open the quickfix list with the compiler messages.
- The build uses `g++ -std=c++20 -O2 -Wall -Wextra -Wshadow -DLOCAL`.

## 11. Plugins, tools, and troubleshooting

- `:Lazy` — plugin manager. Press `I` to install, `U` to update, `S` to sync,
  `C` to clean, `R` to restore the locked versions, `L` for the log.
- `:Mason` — install LSP servers, formatters, and linters. For example:
  `:MasonInstall gopls` or `:MasonInstall prettier`.
- `:LazyExtras` — enable/disable LazyVim language and feature extras.
- `:checkhealth` — check Neovim, plugins, LSP, and external tools.
- `:LazyHealth` — load every plugin and then run the health check.
- `:LazyFormatInfo` — show which formatters are active for the current file.
- Some `:checkhealth` warnings are optional: image/LaTeX/Mermaid support,
  missing optional Treesitter parsers, SQLite-backed picker frecency, UI checks
  that only work in a real terminal, and the empty `vim.pack` directory. They
  do not affect C/C++, Go, TypeScript, Rust, SQL, Markdown, Bash, or the core
  editor.
- `:LazyHealth` loads every plugin before checking; use it when you need the
  most complete health report.
- `Space cl` — LSP information; `:checkhealth vim.lsp` for LSP health.
- `Space cm` — open Mason. `Space D` — open the database sidebar.
- `Space l` — open Lazy.
- If a plugin update breaks something: `:Lazy restore`, then restart Neovim.
- If startup looks broken: run `nvim --headless "+checkhealth" +qa` in a shell,
  or open Neovim and run `:messages` and `:Lazy log`.

The configuration lives in `~/.config/nvim`. Add plugins in
`~/.config/nvim/lua/plugins/*.lua`; do not edit files inside
`~/.local/share/nvim/lazy`.

Your original configuration was backed up before these changes to a
`~/.config/nvim.backup-*` directory. If you ever need to restore it, close
Neovim, move the current `~/.config/nvim` aside, and copy the backup back.

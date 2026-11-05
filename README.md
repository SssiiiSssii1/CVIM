# CVIM

My personal Neovim setup — **LazyVim** underneath, tuned for **competitive programming in C++** (and daily coding in TS/Python/SQL/Bash).

## What's inside

- **LazyVim base** — treesitter, LSP, telescope, which-key, nvim-tree and the usual LazyVim extras; plugin versions pinned in `lazy-lock.json`
- **Competitive-programming toolkit** (`lua/config/competitive.lua`) — plain commands, no plugin needed:

  | Command | What it does |
  |---|---|
  | `:CPNew [name]` | create a new C++ solution file |
  | `:CPInit` | create `input.txt` / `expected.txt` next to the current file |
  | `:CPBuild` | compile the current C++ file |
  | `:CPRun` | compile, then run on stdin |
  | `:CPTest` | compile, run against `input.txt`, diff with `expected.txt` |

  Extra C++ buffer keymaps are added automatically on opening a `.cpp` file.
- **Language & QoL plugins** — TypeScript, SQL, Bash, formatting on save, opencode, discord presence, terminal
- **Docs** — [`BEGINNER_GUIDE.md`](BEGINNER_GUIDE.md) if you're starting out, [`SHORTCUTS.md`](SHORTCUTS.md) for the keymap cheatsheet

## Install

```sh
# back up your old config if it exists
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

git clone git@github.com:SssiiiSssii1/CVIM.git ~/.config/nvim

nvim   # lazy.nvim bootstraps itself and installs everything
```

## Update the config here

Edit files under `~/.config/nvim` as usual, then:

```sh
cpush                 # add -A + commit + push in one shot
cpush "my message"    # with a custom commit message
```

`cpush` is a small shell helper installed in `~/.bashrc`.

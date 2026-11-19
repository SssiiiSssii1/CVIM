# CVIM

My personal Neovim setup — **LazyVim** underneath, tuned for **competitive programming in C++** (and daily coding in TS/SQL/Bash).

## What's inside

- **LazyVim base** — Treesitter, LSP, Snacks explorer/picker, which-key, and the usual LazyVim extras; plugin versions pinned in `lazy-lock.json`
- **Competitive-programming toolkit** (`lua/config/competitive.lua`) — plain commands, no plugin needed:

  | Command | What it does |
  |---|---|
  | `:CPNew [name]` | create a new C++ solution file |
  | `:CPInit` | create `input.txt` / `expected.txt` next to the current file |
  | `:CPBuild` | compile the current C++ file |
  | `:CPRun` | compile, then run on stdin |
  | `:CPTest` | compile, run against `input.txt`, diff with `expected.txt` |

  Extra C++ buffer keymaps are added automatically on opening a `.cpp` file.
- **Web development** — TypeScript/React/Next.js (vtsls, ESLint, oxlint, Blink completion), Tailwind CSS v3/v4, HTML/CSS/Emmet, Prettier or Biome formatting, Next.js snippets, and js-debug configurations
- **Tests and linting** — neotest with Vitest and Jest adapters (picked from `package.json`), oxlint for TS/JS projects that install it, ESLint LSP for projects that use ESLint
- **Language & QoL plugins** — TypeScript, Prisma, SQL, Bash, formatting on save, opencode, discord presence, terminal
- **Docs** — [`BEGINNER_GUIDE.md`](BEGINNER_GUIDE.md) if you're starting out, [`SHORTCUTS.md`](SHORTCUTS.md) for the keymap cheatsheet

## Web / Next.js workflow

- **TypeScript/JavaScript** — `vtsls` with non-relative (tsconfig alias) imports, package.json auto-imports, workspace TypeScript, and inlay hints. Missing imports appear in Blink completion and via `Space cM`; `Space co` organizes imports.
- **React/Next.js** — TSX/JSX treesitter, tag rename/autotag, Emmet, HTML/CSS language servers, and Next.js 16 App Router, Pages Router, route handler, server action, and proxy snippets. Type a prefix such as `npage`, `nlayout`, `nroute`, or `nproxy` in a `.tsx`/`.ts` buffer.
- **Tailwind CSS v3/v4** — class completion and hover inside `className`, `class`, `clsx()`, `cn()`, `cva()`, `cx()`, `tw()`, `twMerge()`, and `tv()`; conflict/variant diagnostics; color swatches for named utilities and arbitrary hex values.
- **Formatting** — ESLint LSP fixes run first, then one formatter per save: Biome when the project has `biome.json`/`biome.jsonc`, otherwise Prettier from the project (or Mason). Format on save is LazyVim's own hook; toggle it with `Space uf`.
- **Debugging** — `Space dc` in a JS/TS buffer offers `Next.js: server-side`, `Next.js: attach to server`, and `Next.js: client-side (Chrome)` next to LazyVim's generic Launch/Attach entries. Client-side debugging requires Chrome or Chromium.
- **Tools** — Mason auto-installs `tailwindcss-language-server`, `html-lsp`, `css-lsp`, `emmet-language-server`, `prisma-language-server`, `sqls`, `biome`, and the configured formatters/linters on first start.

## Tests and linting

- **Tests** — `Space tt` runs the current file, `Space tr` the nearest test, `Space tT` everything, `Space ts` the summary. Both `neotest-vitest` and `neotest-jest` are registered; each adapter activates only when the nearest `package.json` lists that runner, so a Vitest NestJS app and a Jest repository work without switching adapters.
- **oxlint** — nvim-lint runs the project-local `node_modules/.bin/oxlint` on JS/TS buffers when saving and when leaving insert mode. The editor uses oxlint's fast default mode; `bun run lint` remains the authoritative type-aware pass (`--type-aware` needs `oxlint-tsgolint`). Projects without oxlint are unaffected.
- **ESLint** — still enabled for repositories that have an ESLint config. It does not start in this NestJS repo, which has none.

## Prisma and SQL

- **Prisma** — `prismals` provides schema diagnostics, completion, hover, code actions, and formatting; Mason installs `prisma-language-server`, and Treesitter installs the Prisma parser.
- **SQL/PostgreSQL** — `sqls` provides SQL language features and Mason installs the server. For database-aware completion, configure a `config.yml` for sqls in the project; Dadbod remains available for running queries and managing connections. `sqlfluff` continues to provide SQL formatting and linting.

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

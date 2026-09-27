# Jev's Neovim Configuration

Features:

- Basic settings (tabs vs spaces, line numbers, etc.)
- LSP support for different programming languages, most notably
  Python, Rust and Zig.
- Careful choice of plugins: Telescope, Whichkey, Oil and Gitsigns
  are main plugins for the user experience of this config.

## Tree-sitter on machines other than NixOS

The NixOS configs put the tree-sitter CLI and a C compiler on PATH, and
nvim-treesitter builds the parsers it needs at first start. Elsewhere,
`lazysetup.lua` probes for both and picks one of three paths:

- **CLI and compiler present**: build as on NixOS. Neovim 0.12 uses the
  nvim-treesitter `main` branch, which needs `tree-sitter-cli` 0.26 or newer.
  Older Neovim uses the `master` branch, which needs only the compiler plus
  `curl` and `tar` (or `git`).
- **Neovim 0.12 without the toolchain**: use the prebuilt parsers below. Nothing
  is built and nothing is reported.
- **Otherwise**: parsers already present keep working, nothing new is built, and a
  warning after startup names the missing parsers and the packages to install.
  A parser that is present but fails to load (wrong architecture, old glibc, old
  ABI) is also reported, once per language, with the loader's reason. Without a
  parser Neovim falls back to its regex syntax files.

Debian and Ubuntu, with packages from the release itself (checked September 2026):

| Release | neovim | tree-sitter-cli | Branch | What to install |
|---|---|---|---|---|
| Ubuntu 24.04 | 0.9.5 | 0.20.8 | master | `build-essential curl` |
| Debian 13 | 0.10.4 | 0.22.6 | master | `build-essential curl` |
| Ubuntu 26.04 | 0.11.6 | 0.25.9 | master | `build-essential curl` |
| Debian 14 / sid | 0.12.4 | 0.26.11 | main | `build-essential tree-sitter-cli`, or nothing (prebuilt parsers) |

`~/.local/bin` is prepended to PATH, so a CLI or compiler installed there by hand
is found too.

## Prebuilt tree-sitter parsers

`parsers/linux-x86_64/` holds parsers compiled ahead of time, for machines that
have no tree-sitter CLI or no C compiler. When `lazysetup.lua` cannot build it
points nvim-treesitter's `install_dir` at the directory matching
`<sysname>-<machine>`, which puts it on the runtimepath and marks those parsers
as installed, so nothing is built at startup. Machines with the toolchain ignore
the bundle and build their own into `~/.local/share/nvim/site` as before.

The `.so` files depend only on `libc.so.6` and need nothing newer than
GLIBC_2.14, so any current Linux loads them. They are built at tree-sitter ABI
15, which needs Neovim 0.11 or newer, and only the `main` branch (Neovim 0.12)
uses them: `master` pins its own parser revisions and ships matching queries.

To refresh, on a machine that has the CLI and `patchelf`:

    nvim                                    # let it build into ~/.local/share/nvim/site
    cd ~/.config/nvim
    rm -rf parsers/linux-x86_64
    mkdir -p parsers/linux-x86_64
    cp -r ~/.local/share/nvim/site/{parser,parser-info,queries} parsers/linux-x86_64/
    patchelf --remove-rpath parsers/linux-x86_64/parser/*.so

The `patchelf` step matters on NixOS only, where the compiler writes a RUNPATH
full of `/nix/store` paths that mean nothing on another machine.

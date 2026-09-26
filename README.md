# Jev's Neovim Configuration

Features:

- Basic settings (tabs vs spaces, line numbers, etc.)
- LSP support for different programming languages, most notably
  Python, Rust and Zig.
- Careful choice of plugins: Telescope, Whichkey, Oil and Gitsigns
  are main plugins for the user experience of this config.

## Prebuilt tree-sitter parsers

`parsers/linux-x86_64/` holds parsers compiled ahead of time, for machines that
have no tree-sitter CLI and no C compiler. When `lazysetup.lua` finds no CLI it
points nvim-treesitter's `install_dir` at the directory matching
`<sysname>-<machine>`, which puts it on the runtimepath and marks those parsers
as installed, so nothing is built at startup. Machines with the CLI ignore the
bundle and build their own into `~/.local/share/nvim/site` as before.

The `.so` files depend only on `libc.so.6` and need nothing newer than
GLIBC_2.14, so any current Linux loads them.

To refresh, on a machine that has the CLI and `patchelf`:

    nvim                                    # let it build into ~/.local/share/nvim/site
    cd ~/.config/nvim
    rm -rf parsers/linux-x86_64
    mkdir -p parsers/linux-x86_64
    cp -r ~/.local/share/nvim/site/{parser,parser-info,queries} parsers/linux-x86_64/
    patchelf --remove-rpath parsers/linux-x86_64/parser/*.so

The `patchelf` step matters on NixOS only, where the compiler writes a RUNPATH
full of `/nix/store` paths that mean nothing on another machine.

# Jevgeni's Neovim configuration

## TODOs

- ~~[ ] Make it like DataGrip (2023-12-18)~~
  Will not do for now. Most viable plugin for now is dadbod.vim, but I can't
  seem to get it to work with ODBC (odbc adapter not found) and I can't figure
  out what's going on from the docs.
- [ ] Map more Telescope/LSP commands (2023-12-18)

## Environment variables

- For the Elixir language server to work, make sure to set `ELIXIR_LS`
  to the executable of the Elixir language server (full path).
- If there are problems with Python on Windows define an environment
  variable `NVIM_PYTHON_FALLBACK` (can be any value) to try a setup hack.

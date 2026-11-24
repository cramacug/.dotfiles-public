# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Public, shareable half of a two-repo dotfiles setup, managed with [dotbot](https://github.com/anishathalye/dotbot) (vendored as a git submodule at `dotbot/`). Contains generic machine setup (shell, editor, terminal, keyboard, small scripts) with nothing tied to a specific employer or client. Suitable for homelab/VM machines on its own.

A separate private repo layers employer/client-specific git identities and SSH agent config on top by vendoring this repo as a submodule at `public/` and pointing its own `install.conf.yaml` `path:` entries at `public/<path>`.

## Common commands

```bash
./install                 # apply the dotfiles (syncs dotbot submodule, then symlinks everything per install.conf.yaml)
git submodule update --init --recursive   # manually sync the dotbot submodule if needed
```

There is no build/lint/test suite for the dotfiles themselves.

## Architecture

- **`install`**: entrypoint shell script. Syncs the `dotbot` submodule (`git submodule sync` + `update --init --recursive`), then invokes `dotbot/bin/dotbot -d <repo-root> -c install.conf.yaml`.
- **`install.conf.yaml`**: the single source of truth for what gets linked where. Each entry maps a target path under `$HOME` to a source file/dir in this repo. Adding a new dotfile means: (1) add the file under the appropriate top-level directory here, (2) add a `link:` entry pointing the destination at it with `create: true` and usually `force: true`.
- **`- clean: ['~']`** at the top of `install.conf.yaml` means dotbot will remove dangling symlinks in `$HOME` that point back into this repo on every run.
- Top-level directories are organized by tool, not by OS: `zsh/`, `vim/`, `karabiner/`, `ai/`, `scripts/`, `terminal/`, plus `config/` for single-file app settings (`tmux.conf`, `ideavimrc`, exported iTerm2/Vimium/keyboard settings, `htoprc.template`). Keep the top level to these folders and the install/doc files.
- **`zsh/zshrc`** is oh-my-zsh + powerlevel10k based. It sources every `*.zsh` file from `~/.config/zsh/config.d/{common,macOS,linux,custom}/` in that order (those directories are themselves symlinked from `zsh/zsh_configs/{common,macOS,linux}/` — `custom/` is untracked/local-only, and where the private repo could layer additional per-machine config if ever needed). To add shell config, drop a `.zsh` file in the right `zsh/zsh_configs/<os>/` subdirectory rather than editing `zshrc` directly.
- **`scripts/`**: small standalone shell utilities (`bak`, `sfrm`, `trash-restore`, `extract`, `clip`, `ffind`), symlinked into `~/.local/bin`, which is added to `PATH` in `zshrc`.
- **`ai/claude/statusline-command.sh`**: the Claude Code status line script, symlinked to `~/.claude/statusline-command.sh`. Reads the JSON status payload from stdin via `jq` and prints a 2-3 line ANSI-colored status (cwd/branch, model/effort/context-window usage, rate-limit usage).
- **`config/htoprc.template`**: starting htop config, copied to `~/.config/htop/htoprc` by `./install` only if that file does not exist (htop rewrites it constantly, so the live file is deliberately not linked or tracked; `htoprc` is gitignored). Edit the template to change the starting point for new machines.
- **`terminal/`**: exported macOS Terminal.app `.terminal` profiles — not currently wired into `install.conf.yaml`, imported manually.

## Notes

- Changes to files under `zsh/`, `vim/`, etc. only take effect in a live shell after re-running `./install` (to (re)create symlinks) and opening a new shell / re-sourcing.
- `dotbot/` is a vendored third-party submodule — avoid modifying it; upstream changes should come from bumping the submodule, not hand-edits.
- Keep this repo free of anything employer/client-specific (identities, internal hostnames, work vault names, etc.) — that's what the private overlay repo is for.

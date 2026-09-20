# dotfiles (WSL / bash / ble.sh, PSReadLine-like)

Personal shell setup for **Windows Terminal + WSL (Ubuntu) + bash + ble.sh**,
made to feel like PowerShell's PSReadLine (Windows edit mode): inline and
list-view history predictions, `F2` to switch views, `Ctrl+C`/`Esc`,
clipboard-bound kill ring, and PSReadLine key bindings.

## Contents

| In repo | Installed as | What it is |
|---|---|---|
| `bash/bashrc` | `~/.bashrc` | shell init: loads ble.sh, oh-my-posh, fzf, dotnet/podman completion |
| `bash/bash_aliases` | `~/.bash_aliases` | aliases/functions ported from a PowerShell profile |
| `bash/blerc` | `~/.blerc` | **the main part**: all ble.sh customizations |
| `oh-my-posh/my-capr4n.omp.json` | `~/.config/oh-my-posh/my-capr4n.omp.json` | prompt theme |

Everything is an *overlay* on ble.sh: no file inside the ble.sh installation is
patched. `~/.blerc` only uses public ble.sh APIs (`ble-bind`, `ble-face`,
`blehook`, `ble/...` helpers) and user-defined widgets.

## Install

```bash
git clone <this repo> ~/dotfiles
~/dotfiles/install.sh          # symlinks into $HOME, backs up existing files
exec bash                      # or: source ~/.bashrc
```

## Requirements

- **ble.sh 0.4.0-nightly** (the config is written against the nightly API).
  Install without touching the shell:
  ```bash
  git clone --recursive --depth 1 --shallow-submodules \
    https://github.com/akinomyoga/ble.sh.git ~/.local/share/blesh
  make -C ~/.local/share/blesh install PREFIX=~/.local
  ```
  Or use the official installer from https://github.com/akinomyoga/ble.sh.
- **WSL with Windows interop** for the clipboard (`clip.exe`, `powershell.exe`)
  and for `explorer.exe` in `load-solution`. On plain Linux the clipboard falls
  back to ble.sh's own detection (xclip/pbpaste/tmux); the Windows-specific
  aliases (`clip`, `goto ...`) simply do not apply.
- Optional: `fzf`, `oh-my-posh`, `podman`, .NET SDK — the init has guards, so
  missing tools are skipped.

## Local secrets (not in git)

`~/.bashrc` sources `~/.config/opencode/secrets.env` if it exists. Put API keys
there (e.g. `export DEEPSEEK_API_KEY=...`, `chmod 600`). The file is
intentionally absent from the repo.

## What the ble.sh config does

- `F2` toggles the prediction view **inline** (ghost text) / **list**
  (vertical menu); the choice is remembered in
  `~/.config/blesh/prediction-view`.
- History lines are shown as candidates: lines **starting with** the typed text
  first, otherwise lines **containing** it; the matching part is highlighted
  (turquoise) and the rest is grey. The list is rebuilt on every keystroke from
  a cached, deduplicated history (rebuilt only when `HISTCMD` changes).
- `Tab` accepts / enters the menu and cycles; `Esc` closes the menu and
  otherwise discards the line; `Space` narrows the list.
- PSReadLine (Windows mode) keys: `Ctrl+C` copy-selection-or-cancel,
  `Ctrl+V`/`Shift+Insert` paste, `Ctrl+Z`/`Ctrl+Y` undo/redo,
  `Ctrl+Space` menu complete, `Ctrl+Home`/`Ctrl+End` kill to start/end,
  `Ctrl+Backspace`/`Ctrl+Delete` kill word. Every kill/copy also goes to the
  Windows clipboard (kill ring == clipboard), like PSReadLine.

## Known differences from PSReadLine

- `Ctrl+A` is `beginning-of-line` (PSReadLine: SelectAll; line start is `Home`).
- `Ctrl+X` is an emacs prefix (PSReadLine: Cut).
- `Ctrl+Z` undoes one edit at a time (PSReadLine groups edits).
- `F3/F8`, `Ctrl+]`, `Alt+a`, multi-line `Ctrl+Enter`/`Shift+Enter` are not
  reproduced.

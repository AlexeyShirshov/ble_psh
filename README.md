# ble.sh overlay (PSReadLine-like)

A thin **overlay on [ble.sh](https://github.com/akinomyoga/ble.sh)** that makes
`Windows Terminal + WSL + bash` feel like PowerShell's PSReadLine (Windows edit
mode): inline and list-view history predictions, `F2` to switch views, and
PSReadLine key bindings with a clipboard-bound kill ring.

No file of the ble.sh installation itself is patched — everything lives in a
single `blerc` file and uses public ble.sh APIs (`ble-bind`, `ble-face`,
`blehook`, user widgets).

## Contents

| File | Purpose |
|---|---|
| `blerc` | the overlay (installed as `~/.blerc`) |
| `blesh/` | git submodule: the pinned [ble.sh fork](https://github.com/AlexeyShirshov/ble.sh) |
| `install.sh` | installs ble.sh from the submodule, wires `~/.bashrc`, links `~/.blerc` |

## Install

```bash
git clone --recurse-submodules https://github.com/AlexeyShirshov/dotfiles.git ~/sources/dotfiles
~/sources/dotfiles/install.sh
exec bash
```

`install.sh` fetches the submodule, runs `make install PREFIX=$HOME/.local`
(→ `~/.local/share/blesh`), appends the two ble.sh lines to `~/.bashrc` if they
are missing, and symlinks `~/.blerc` (existing file is backed up).

## Requirements

- **WSL with Windows interop** for the clipboard (`clip.exe`, `powershell.exe`).
  On plain Linux the clipboard falls back to ble.sh's own detection
  (xclip/pbpaste/tmux), and `ble/edit/get-clipboard` is left untouched.
- `bash` ≥ 4.4, `make`, `git`.
- Optional: `fzf` (Ctrl+T/Ctrl+R via `contrib/integration`), `oh-my-posh`.

## What the overlay does

- `F2` toggles the prediction view **inline** (ghost text) / **list** (vertical
  menu); the choice is remembered in `~/.config/blesh/prediction-view`.
- History lines are shown as candidates: lines **starting with** the typed text
  first, otherwise lines **containing** it; the match is highlighted (turquoise),
  the rest is grey. The list is rebuilt per keystroke from a cached,
  deduplicated history (rebuilt only when `HISTCMD` changes).
- `Tab` accepts / enters the menu and cycles; `Esc` closes the menu and
  otherwise discards the line; `Space` narrows the list.
- PSReadLine (Windows mode) keys: `Ctrl+C` copy-selection-or-cancel,
  `Ctrl+V` / `Shift+Insert` paste, `Ctrl+Z` / `Ctrl+Y` undo/redo,
  `Ctrl+Space` menu complete, `Ctrl+Home` / `Ctrl+End` kill to start/end,
  `Ctrl+Backspace` / `Ctrl+Delete` kill word. Every kill/copy also reaches the
  Windows clipboard (kill ring == clipboard), like PSReadLine.

## Known differences from PSReadLine

- `Ctrl+A` is `beginning-of-line` (PSReadLine: SelectAll; line start is `Home`).
- `Ctrl+X` is an emacs prefix (PSReadLine: Cut).
- `Ctrl+Z` undoes one edit at a time (PSReadLine groups edits).
- `F3/F8`, `Ctrl+]`, `Alt+a`, multi-line `Ctrl+Enter`/`Shift+Enter` are not
  reproduced.

## Maintaining the ble.sh fork

```bash
cd blesh
git remote add upstream https://github.com/akinomyoga/ble.sh   # once
git fetch upstream && git merge upstream/master                # take upstream
git push origin master                                         # to the fork
cd .. && git add blesh && git commit -m "update ble.sh"
```

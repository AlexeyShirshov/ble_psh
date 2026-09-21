#!/usr/bin/env bash
# Install the ble.sh overlay:
#   1. fetch ble.sh (the pinned fork) from the git submodule,
#   2. install it into $HOME/.local (=> ~/.local/share/blesh),
#   3. make sure ~/.bashrc loads ble.sh,
#   4. symlink the overlay (~/.blerc).
#
# Nothing else from the shell setup is managed here.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

# 0. prerequisites
for cmd in bash make git fzf; do
  command -v "$cmd" >/dev/null 2>&1 ||
    echo "warning: '$cmd' not found — install it (see README Requirements)" >&2
done

# 1. submodule (ble.sh fork)
git -C "$repo" submodule update --init --recursive --depth 1

# 2. install ble.sh from the fork
make -C "$repo/blesh" install PREFIX="$HOME/.local"

# 3. make ~/.bashrc load ble.sh (idempotent). ble-attach must stay last.
bashrc=$HOME/.bashrc
touch "$bashrc"
if ! grep -q 'blesh/ble.sh' "$bashrc"; then
  {
    echo
    echo '# ble.sh (overlay: ~/sources/ble_psh)'
    echo '[[ $- == *i* ]] && source -- "$HOME/.local/share/blesh/ble.sh" --attach=none'
  } >> "$bashrc"
fi
if ! grep -q 'ble-attach' "$bashrc"; then
  echo '[[ ! ${BLE_VERSION-} ]] || ble-attach' >> "$bashrc"
fi

# 4. symlink the overlay
stamp=$(date +%Y%m%d-%H%M%S)
dst=$HOME/.blerc
if [[ -e $dst || -L $dst ]] && [[ $(readlink -f -- "$dst" 2>/dev/null) != "$repo/blerc" ]]; then
  mv -- "$dst" "$dst.bak-$stamp"
  echo "backup   $dst -> $dst.bak-$stamp"
fi
ln -sf -- "$repo/blerc" "$dst"
echo "linked   $dst -> $repo/blerc"

echo
echo "done. Start a new shell, or run: exec bash"

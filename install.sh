#!/usr/bin/env bash
# Install these dotfiles by symlinking them into $HOME. Existing files are
# backed up with a ".bak-<timestamp>" suffix.
set -euo pipefail

repo=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
stamp=$(date +%Y%m%d-%H%M%S)

link() { # link <path-in-repo> <path-in-HOME>
  local src=$1 dst=$2
  mkdir -p "$(dirname -- "$dst")"
  if [[ -e $dst || -L $dst ]]; then
    if [[ $(readlink -f -- "$dst" 2>/dev/null) == "$src" ]]; then
      echo "ok       $dst"
      return 0
    fi
    mv -- "$dst" "$dst.bak-$stamp"
    echo "backup   $dst -> $dst.bak-$stamp"
  fi
  ln -s -- "$src" "$dst"
  echo "linked   $dst -> $src"
}

link "$repo/bash/bashrc"       "$HOME/.bashrc"
link "$repo/bash/bash_aliases" "$HOME/.bash_aliases"
link "$repo/bash/blerc"        "$HOME/.blerc"
link "$repo/oh-my-posh/my-capr4n.omp.json" \
     "$HOME/.config/oh-my-posh/my-capr4n.omp.json"

echo
echo "done. Restart the shell or: source ~/.bashrc"

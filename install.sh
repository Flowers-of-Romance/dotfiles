#!/usr/bin/env bash
set -euo pipefail

# このスクリプトがあるディレクトリ = dotfilesのルート
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- OS判定 ---
case "$(uname -s)" in
  Darwin) OS=mac ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS=wsl; else OS=linux; fi
    ;;
  *) OS=unknown ;;
esac
echo "detected OS: $OS"

# --- 共通: symlinkヘルパ（既存ファイルは .bak に退避してから symlink）---
link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "backup: $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -snf "$src" "$dst"
  echo "link:   $dst -> $src"
}

# --- どの環境でも: tmux は symlink ---
link "$DOTFILES/tmux/.tmux.conf" "$HOME/.tmux.conf"

# --- wezterm: 環境ごとに配置方法を変える ---
case "$OS" in
  mac|linux)
    # ネイティブアプリなので symlink でOK
    link "$DOTFILES/wezterm/wezterm.lua"  "$HOME/.config/wezterm/wezterm.lua"
    link "$DOTFILES/wezterm/keybinds.lua" "$HOME/.config/wezterm/keybinds.lua"
    ;;
  wsl)
    # WindowsアプリなのでWSLのsymlinkを辿れない → コピー
    # Windowsのユーザー名を動的に取得（ベタ書きしない）
    WIN_USER="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r\n')"
    WIN_WEZTERM="/mnt/c/Users/${WIN_USER}/.config/wezterm"
    if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/${WIN_USER}" ]; then
      mkdir -p "$WIN_WEZTERM"
      cp "$DOTFILES/wezterm/wezterm.lua"  "$WIN_WEZTERM/"
      cp "$DOTFILES/wezterm/keybinds.lua" "$WIN_WEZTERM/"
      echo "copy:   wezterm -> $WIN_WEZTERM"
    else
      echo "skip:   Windowsユーザーが特定できないため wezterm はスキップ"
    fi
    ;;
  *)
    echo "skip:   未対応OSのため wezterm はスキップ"
    ;;
esac

echo "done."

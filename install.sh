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

# --- どの環境でも: Claude Code のキーバインド ---
link "$DOTFILES/claude/keybindings.json" "$HOME/.claude/keybindings.json"

# --- mac: Karabiner はGUIが設定ファイルを書き換えるためディレクトリごと symlink ---
if [ "$OS" = mac ]; then
  link "$DOTFILES/karabiner" "$HOME/.config/karabiner"
fi

# --- どの環境でも: bin/ の実行スクリプトを ~/.local/bin に symlink ---
if [ -d "$DOTFILES/bin" ]; then
  for f in "$DOTFILES/bin/"*; do
    [ -f "$f" ] && link "$f" "$HOME/.local/bin/$(basename "$f")"
  done
fi

# --- bash: dotfilesのbashスニペットを ~/.bashrc から読み込む（冪等）---
# マーカーで囲んだブロックを ~/.bashrc に1度だけ追記する
BASHRC="$HOME/.bashrc"
MARKER_BEGIN="# >>> dotfiles bash >>>"
MARKER_END="# <<< dotfiles bash <<<"
if [ -f "$BASHRC" ] && grep -qF "$MARKER_BEGIN" "$BASHRC"; then
  echo "skip:   ~/.bashrc は既に dotfiles ブロックあり"
else
  {
    echo ""
    echo "$MARKER_BEGIN"
    echo "for f in \"$DOTFILES/bash/\"*.sh; do [ -r \"\$f\" ] && . \"\$f\"; done"
    echo "$MARKER_END"
  } >> "$BASHRC"
  echo "append: dotfiles bash ブロックを ~/.bashrc に追記"
fi

# --- git: 共有 gitconfig (delta + alias) を ~/.gitconfig から include（冪等）---
GIT_INC="$HOME/dotfiles/git/delta.inc"
if git config --global --get-all include.path 2>/dev/null | grep -qxF "~/dotfiles/git/delta.inc"; then
  echo "skip:   ~/.gitconfig に既に git/delta.inc の include あり"
else
  git config --global --add include.path "~/dotfiles/git/delta.inc"
  echo "add:    include.path ~/dotfiles/git/delta.inc を ~/.gitconfig に追加"
fi

# --- git-delta（差分ビューア）を OS ごとに導入 ---
if command -v delta >/dev/null 2>&1; then
  echo "skip:   git-delta は既に導入済み ($(delta --version))"
else
  case "$OS" in
    wsl|linux) sudo apt-get install -y git-delta ;;
    mac)       brew install git-delta ;;
    *)         echo "skip:   未対応OSのため git-delta はスキップ" ;;
  esac
fi

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

#!/usr/bin/env bash
# サクラエディタ設定を dotfiles から AppData へ復元する
# 使い方: bash restore.sh   （サクラエディタは閉じてから実行すること）
set -e
DST="/mnt/c/Users/USERNAME/AppData/Roaming/sakura"
SRC="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$DST"
for f in "$SRC"/*.ini; do
  cp -v "$f" "$DST/$(basename "$f")"
done
echo "復元完了。サクラエディタを起動して反映を確認してください。"

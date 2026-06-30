#!/usr/bin/env bash
# サクラエディタ設定を dotfiles から %APPDATA%\sakura へ復元する
# 使い方: bash restore.sh   （サクラエディタは閉じてから実行すること）
set -e
SRC="$(cd "$(dirname "$0")" && pwd)"

# Windows の %APPDATA% を動的取得（マシン非依存・ユーザ名ハードコードなし）
WIN_APPDATA="$(cmd.exe /c "echo %APPDATA%" 2>/dev/null | tr -d "\r\n")"
DST="$(wslpath "$WIN_APPDATA")/sakura"

mkdir -p "$DST/col"
for f in "$SRC"/*.ini;     do cp -v "$f" "$DST/$(basename "$f")"; done
for f in "$SRC"/col/*.col; do cp -v "$f" "$DST/col/$(basename "$f")"; done
echo "復元完了: $DST"

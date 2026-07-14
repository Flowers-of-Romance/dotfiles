# shellcheck shell=bash
# tmux 自動attach: 端末を開いたら既存セッション(main)に戻る。無ければ新規作成。
# - 対話シェルのみ / すでにtmux内なら何もしない（無限ループ防止）
# - SSH接続やVS Code等の埋め込み端末では発動させない（必要なら下のガードを調整）
if command -v tmux >/dev/null 2>&1 \
   && [[ $- == *i* ]] \
   && [[ -z "${TMUX:-}" ]] \
   && [[ -z "${SSH_CONNECTION:-}" ]] \
   && [[ "${TERM_PROGRAM:-}" != "vscode" ]]; then
  tmux attach -t main 2>/dev/null || tmux new -s main
fi

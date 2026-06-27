# ローカル専用の秘密(~/.secrets)があれば読み込む。
# ~/.secrets はAPIキー等を入れる平文ファイル。chmod 600 にして git には絶対に載せないこと。
# 例:  export OPENAI_API_KEY=sk-...
[ -r "$HOME/.secrets" ] && . "$HOME/.secrets"

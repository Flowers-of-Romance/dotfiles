# shellcheck shell=bash
# starship プロンプト（未導入なら何もしない。導入は install.sh が行う）
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

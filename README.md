# dotfiles

WSL / macOS / 素のLinux に対応した個人用 dotfiles。

## 構成

```
~/dotfiles/
├── install.sh          # OS判定して配置を自動化（mac/wsl/linux）
├── .gitignore
├── tmux/
│   └── .tmux.conf
├── starship/
│   └── starship.toml   # プロンプト設定（starship 本体は install.sh が導入）
└── wezterm/
    ├── wezterm.lua     # target_triple でOSごとに分岐
    └── keybinds.lua
```

## セットアップ

```bash
git clone <this-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## 配置方法（環境ごと）

| 対象 | mac / linux | WSL |
|------|-------------|-----|
| tmux | symlink | symlink |
| starship | symlink (`~/.config/starship.toml`) | symlink |
| wezterm | symlink (`~/.config/wezterm/`) | **コピー** (`/mnt/c/Users/<user>/.config/wezterm/`) |

- **tmux** はsymlinkなので、`~/dotfiles/` の中を編集すれば即反映。
- **WSLのwezterm** はWindowsアプリでWSLのsymlinkを辿れないため `install.sh` でコピー配置。
  リポジトリ側 (`wezterm/wezterm.lua`) を編集 → `./install.sh` を再実行してWindowsへ反映。
  `automatically_reload_config = true` なので反映自体は自動。
- 既存ファイルは install 実行時に `*.bak` へ退避するので安全。

## 依存ツール（install.sh が自動導入）

- **starship**: プロンプト。mac は brew、linux/WSL は公式インストーラで導入し、
  zsh は `~/.zshrc` に init を追記、bash は `bash/starship.sh` 経由で有効化。
- **git-delta**: git の差分ビューア。
- **Nerd Font**: starship / wezterm の設定がグリフ（  󰌾 など）を使うため必須。
  wezterm 側は HackGen Console NF を指定している（フォント自体の導入は手動）。

## 注意

- WSLでは `cmd.exe /c 'echo %USERNAME%'` でWindowsユーザー名を動的取得（ベタ書きしない）。

# Sakura Editor 設定

サクラエディタ (sakura.exe / Win64) の設定を管理する。

## 含まれるもの
- `sakura.ini`        … メイン設定（履歴セクションは除外済み）
- `*.ini`（タイプ別） … テキスト/Java/COBOL/基本/設定ファイル/MS-DOSバッチ の各タイプ別設定
- `col/*.col`         … 色設定ファイル（cobol/java/text）

## 除外している履歴セクション
dotfiles 化にあたり、以下のマシン依存・個人履歴セクションは sakura.ini から削除している:
`[MRU]` `[Keys]` `[Cmd]` `[Folders]` `[Grep]`

## 設定の保存先（実機）
`%APPDATA%\sakura\`
（exe側 `sakura.exe.ini` で MultiUser=1 / UserRootFolder=0 のため AppData に保存される）

## 復元
    bash restore.sh
※ シンボリックリンクは不可。サクラは終了時に sakura.ini を丸ごと上書きし、
  履歴が再混入するため、明示コピー方式（restore.sh）で反映する。

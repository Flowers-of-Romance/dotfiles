# macos

macOS 固有の設定（`defaults` ドメイン）。

## symbolichotkeys.plist

システムのキーボードショートカット（Mission Control / デスクトップを表示 / 入力ソース切替 など）。

- `com.apple.symbolichotkeys` ドメインを XML でエクスポートしたもの。
- 個人情報は含まない（キーコード・修飾キーの数値・enabled フラグのみ）。
- `cfprefsd` が実ファイルを書き換えるため **symlink 不可**。`install.sh` が
  `defaults import` で流し込む。

### 現在の設定を書き出し直す（変更したとき）

```bash
defaults export com.apple.symbolichotkeys macos/symbolichotkeys.plist
plutil -convert xml1 macos/symbolichotkeys.plist   # 差分を読めるよう XML 化
```

### 手動で復元する

```bash
defaults import com.apple.symbolichotkeys macos/symbolichotkeys.plist
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

# Explzh 設定（レジストリ）

Explzh (アーカイバ) の設定を `HKCU\Software\Pon\Explzh` から書き出したもの。

## 含まれるもの
`Explzh-settings.reg` … 設定のみ（履歴・UI状態・ライセンス・個人パスは除去済み）

## 除去したキー（履歴・状態・個人情報）
CompressDirHistory / DirHistory / BarState / ExtractDlgSize / LogDlgSize /
WindowSize / FtpSite / UserInfo64(ライセンス) / Folders / UpModule
さらに Option\RegPath（個人パス）を個別除去。

## 残しているもの
Option / Settings / Column / Fonts / Editor / ShellExt / Themes / WindowsApps /
DigitalSign / 各アーカイバDLL設定 (7-Zip,7z,Cab32,RAR,Tar32,Zip32 ほか)

## 適用
ダブルクリックで取り込み、または:
    reg import Explzh-settings.reg
※ UserInfo64(ライセンス登録) は含まないので、別途 Explzh 側で登録すること。

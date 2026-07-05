# git-delta 差分ビューア + Claude 変更抽出 alias（cross-platform）。
# delta 本体の導入は install.sh が OS 別に行う（wsl→apt / mac→brew）。
# ~/.gitconfig から [include] path = ~/dotfiles/git/delta.inc で読み込む。
[core]
	pager = delta
[interactive]
	diffFilter = delta --color-only
[delta]
	navigate = true
	line-numbers = true
	side-by-side = true
	hyperlinks = true
[merge]
	conflictStyle = zdiff3
[alias]
	claude-log = log --oneline --grep=\"Co-Authored-By: Claude\"
	claude-diff = log -p --grep=\"Co-Authored-By: Claude\"

alias gdol='git diff "origin/$(git branch --show-current)" $(git branch --show-current)'
alias gCOM='git ls-tree --full-tree -r --name-only HEAD | fzf | (read file; git diff HEAD:$file origin/main:$file)'
alias gBackup='git checkout -b backup/$(git branch --show-current) && git checkout -'

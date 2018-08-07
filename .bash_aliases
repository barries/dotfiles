alias "l=ls -1"
alias "e=nvim"
alias "be=nvim -u ~barries/alien_init_nvim"
alias "m=make"
alias "mm=make -j10  -O -k"
alias "cm=clear && make"

alias "i=perl -I../Tools/ivcg/lib ../Tools/ivcg/script/ivcg"

# For using my vim setup from other's accounts:
alias "be=XDG_CONFIG_HOME=~barries/.config nvim --cmd 'set rtp^=~barries/.vim' --cmd 'set rtp-=~/.vim'"

# git

alias "fetch=git fetch --all && git remote prune origin"
alias "push=git push"
alias "pull=git pull"

alias "grc=git rebase --continue"
alias "gr0=cd \`pwd | perl -pe 's{/r\d/}{/r0/}'\`"
alias "gr1=cd \`pwd | perl -pe 's{/r\d/}{/r1/}'\`"
alias "gr2=cd \`pwd | perl -pe 's{/r\d/}{/r2/}'\`"

" Use my existing .vim* directories
set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
" source ~/.vimrc
source ~barries/.vimrc " Using my config from others' accounts

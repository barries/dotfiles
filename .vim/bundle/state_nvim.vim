if g:dein#_cache_version !=# 150 || g:dein#_init_runtimepath !=# '/home/barries/.vim,/home/barries/.config/nvim,/etc/xdg/nvim,/home/barries/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/usr/local/share/nvim/runtime,/usr/local/lib/nvim,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/home/barries/.local/share/nvim/site/after,/etc/xdg/nvim/after,/home/barries/.config/nvim/after,/home/barries/.vim/after,/home/barries/.vim/bundle/repos/github.com/Shougo/dein.vim' | throw 'Cache loading error' | endif
let [plugins, ftplugin] = dein#load_cache_raw(['/home/barries/.config/nvim/init.vim'])
if empty(plugins) | throw 'Cache loading error' | endif
let g:dein#_plugins = plugins
let g:dein#_ftplugin = ftplugin
let g:dein#_base_path = '/home/barries/.vim/bundle'
let g:dein#_runtime_path = '/home/barries/.vim/bundle/.cache/init.vim/.dein'
let g:dein#_cache_path = '/home/barries/.vim/bundle/.cache/init.vim'
let &runtimepath = '/home/barries/.vim,/home/barries/.config/nvim,/etc/xdg/nvim,/home/barries/.local/share/nvim/site,/usr/local/share/nvim/site,/usr/share/nvim/site,/home/barries/.vim/bundle/repos/github.com/Shougo/dein.vim,/home/barries/.vim/bundle/.cache/init.vim/.dein,/usr/local/share/nvim/runtime,/home/barries/.vim/bundle/.cache/init.vim/.dein/after,/usr/local/lib/nvim,/usr/share/nvim/site/after,/usr/local/share/nvim/site/after,/home/barries/.local/share/nvim/site/after,/etc/xdg/nvim/after,/home/barries/.config/nvim/after,/home/barries/.vim/after'
filetype off

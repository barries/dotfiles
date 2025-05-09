if &compatible
  set nocompatible " Be iMproved
endif

"filetype plugin indent on
"syntax enable

"au FileType c   setlocal suffixesadd+=.c,.cpp,.h,.hpp,.lua
"au FileType cpp setlocal suffixesadd+=.c,.cpp,.h,.hpp,.lua
"au FileType c   setlocal suffixesadd+=.c,.cpp,.h,.hpp,.lua

" Appearance
if !has("nvim")
    set ttymouse=xterm2 " Allow mouse to drag splits
    set t_Co=256
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

set termguicolors

" FZF Config ----------------

set runtimepath^=~/.fzf

function! s:handle_fzf_enter(cmd, lines) abort
  try
    let autochdir = &autochdir
    set noautochdir
    call reverse(a:lines)
    if len(a:lines) >= 1
      execute 'e' remove(a:lines, 0)
    endif
    for item in a:lines
      execute a:cmd item
    endfor
  finally
    let &autochdir = autochdir
    silent! autocmd! fzf_swap
  endtry
endfunction

let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': function('s:handle_fzf_enter', ['split' ]),
  \ 'ctrl-v': function('s:handle_fzf_enter', ['vsplit']),
  \ '':       function('s:handle_fzf_enter', ['vsplit']),
\ }

function! s:shortpath()
  let short = fnamemodify(getcwd(), ':~:.')
  if !has('win32unix')
    let short = pathshorten(short)
  endif
  let slash = '/'
  return empty(short) ? '~'.slash : short . (short =~ escape(slash, '\').'$' ? '' : slash)
endfun

function! s:Handle_FZF_filelist(fn)
    execute "e" a:fn
    if s:line_number >= 0
        execute s:line_number
    endif
endfunc

function! E_command(...)
    let opts = {
        \ 'options': ['--multi', '--select-1', '--tiebreak=end,length'],
        \ 'window': 'vertical aboveleft 100new'
    \ }

    let args = deepcopy(a:000)

    let s:line_number = -1  " -1: no line number
    if len(args)
        let last_arg = args[-1]

        " Let users paste in compiler errors like "Foo/Bar.cpp:10"
        let offset = match(last_arg, ":")
        if offset >= 0
            if offset > 0
                let args[-1] = last_arg[0:offset-1]
            elseif len(args) > 1
                let args = args[0:len(args)-2]
            else
                let args = []
            end
            let s:line_number = last_arg[offset+1:]
        endif
    endif

    let prompt = s:shortpath()
    if len(args)
        let path = expand(args[0])
        if isdirectory(path)
            let opts.dir = substitute(substitute(remove(args, 0), '\\\(["'']\)', '\1', 'g'), '[/\\]*$', '/', '')
            let prompt   = opts.dir . "/"
        else
            let dir = fnamemodify(path, ":h")
            let fn  = fnamemodify(path, ":t")
            if isdirectory(dir)
                let opts.dir = dir
                let prompt   = opts.dir . "/"
                let args[0]  = fn
            endif
        endif

        if len(args)
            call add(opts.options, '--query='.join(args))
        endif
    endif

    let prompt = strwidth(prompt) < &columns - 20 ? prompt : '> '
    call extend(opts.options, ['--prompt', prompt])

    let opts.sink = function('s:Handle_FZF_filelist')

    call fzf#run(fzf#wrap('E', opts))
endfunc

command! -nargs=* -complete=file_in_path E     call E_command(<f-args>)

command! -nargs=* -range                 Align call Tabularize(<f-args>)

"End FZF------------------------------------

function! s:RunShellCommand(cmdline)
    let expanded_cmdline = a:cmdline
    for part in split(a:cmdline, ' ')
        if part[0] =~ '\v[%#<]'
            let expanded_part = fnameescape(expand(part))
            let expanded_cmdline = substitute(expanded_cmdline, part, expanded_part, '')
        endif
    endfor
    tabnew
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
    execute 'read !'. expanded_cmdline
    execute '1d'
    setlocal nomodifiable
    1
endfunc

command! -complete=shellcmd -nargs=+ Shell call s:RunShellCommand(<q-args>)

autocmd VimEnter * call VimEnter_Initialize()

" Called after plugins are loaded, which is needed to override mapping set by plugins (like vim-mark's)
function! VimEnter_Initialize()

let g:VimEnter_Initialize = 1

" cabbrev <expr> e (getcmdtype()==':' && getcmdpos()<=2 ? 'E' : 'e')
cmap <expr> <leader><Tab> CmdLineTab()

vmap <leader>a :Align /

" Easier macro recording and playback using register q
map <leader>q qq
map <leader>. @q

set wildcharm=<Tab>

function! CmdLineTab()
    if getcmdtype() != ':'
        return "\<Tab>"
    end

    let line = getcmdline()

    if line !~ '^e\(d\(i\(t\)\?\)\?\)\?'
        return "\<Tab>"
    end

    let args = split(line)

    call remove(args, 0) " Discard :edit

    let path = expand(args[0])

    if filereadable(path)
        return "\<Esc>:edit " . args[0] . "\<CR>"
    endif

    return "\<Esc>:call E_command('" . join(args). "')\<CR>"
endfunc

command! ClearTerminal call ClearTerminal()

function! ClearRegs()
    let regs=split('abcdefghijklmnopqrstuvwxyz0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [], 'c')
    endfor
endfunction

command! ClearRegs :call ClearRegs()

" Disabled: this overrides the foreground in all rows set cursorcolumn
" Disabled: this overrides the foreground in all rows set cursorline

" Not implemnted yet in nvim: au OptionSet diff let &cul=v:option_new
"
augroup MyCursorLine
  au!
"  au FilterWritePost * if  &diff | let &cursorline=1 | let &cursorcolumn=1 | endif
"  au BufEnter        * if !&diff | let &cursorline=0 | let &cursorcolumn=0 | endif
augroup end

if &diff
    set cursorline
end

set diffopt+=algorithm:histogram " histogram: better performance than patience or myers
set diffopt+=indent-heuristic    " indent-heuristic: better context vs. content differentiation, apparently
set diffopt+=context:3           " 3: allow more diffs to be seen than the default (6)
set diffopt+=linematch:100       " align similar lines; 100: allow a reasonable hunk size (for now)
set diffopt+=vertical            " so :diffsplit does a vertical split

set foldopen-=hor                " hor: horizonal movement

function! FoldNonmatchingLines()
    set foldcolumn=3
    set foldlevel=0
    set foldmethod=expr
    set foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\|\|(getline(v:lnum+1)=~@/)?1:2
    set foldenable
    autocmd BufLeave <buffer> set nofoldenable | set foldcolumn=0
    autocmd BufEnter <buffer> set foldenable   | set foldcolumn=3
endfunction

command! FoldNonmatchingLines call FoldNonmatchingLines(<f-args>)

" Status Line Appearance

set fillchars=vert:\ ,fold:+,diff:\     " Remove pipe character from vertical splits, uses ' ' for deleted line in diff output

function! GetStatusLineRHS()
    return "%=%9*%l,%3c%*\ %3p%% [%n]"                      " %=: switch to right; %9:*: User9 color; %l: line#; %c: col number; %p: percent
endfunction

set statusline=%f:%l\                   " %f: Filename
set statusline+=%4*%m%5*%r%w%h%q%*      " %4*: User4 color; %m: modified; %5*: User5Color; %r: readonlyflag; %w: preview flag%h: help; %q: quickfix list; %*: revert color
let &statusline=&statusline . GetStatusLineRHS()

if has("nvim")
    autocmd! TermOpen
    autocmd TermOpen * let &l:statusline="%{b:term_title}" . GetStatusLineRHS()
    autocmd TermOpen * set winfixheight
    autocmd TermOpen * set nonu
    autocmd TermOpen * set norelativenumber

    map     <silent> <C-W>! <C-W><Insert>:term<CR>:startinsert<CR>
    imap    <silent> <C-W>! <Esc><C-W>!
    vmap    <silent> <C-W>! <Esc><C-W>!
    omap    <silent> <C-W>! <Esc><C-W>!

end

map     <silent> <C-W><Insert> :split<CR><C-W><S-J>
imap    <silent> <C-W><Insert> <Esc><C-W><Insert>
vmap    <silent> <C-W><Insert> <Esc><C-W><Insert>
omap    <silent> <C-W><Insert> <Esc><C-W><Insert>

if has("nvim")
    set inccommand=nosplit
endif

" highlight tabs and trailing whitespace, put $ for extending offscreen
set list
set listchars=tab:→\ ,trail:·,extends:»,precedes:«,nbsp:☠
set showbreak=»
set linebreak

set display+=uhex     " Display unprintables as <00> hex codes rather than ^@ control codes
set display+=lastline " Display partial last line

set hlsearch          " highlight search terms

set completeopt=longest,menuone " longest: add longest common text, then show menu even if only one option, to show source of option

" State files
set dir=~/tmp/vim//
set bdir=~/tmp/vim//
set undodir=~/tmp/vim//
set undofile    " Create undo files so you can undo past file close (>= 7.3)

"set spell
set spellfile=~/.vim/spellfile.en.add

set mouse=a

set updatetime=250 " Decrease swap file update (flush) time
set ttimeoutlen=10 " Make <ESC> out of insert mode fast

set nowrap        " don't wrap lines
set expandtab
set tabstop=4     " a hard tab is eight spaces
set softtabstop=4 " indent w/ TAB key like so
set shiftwidth=4  " number of spaces to use for autoindenting
set noshiftround  " Don't align all lines' indents when indenting/outdenting
set backspace=indent,eol,start
                  " allow backspacing over everything in insert mode
set autoindent    " always set autoindenting on
set copyindent    " copy the previous indentation on autoindenting

set cinoptions=(s,m1 " (s,m1: indent close paren under first in open paren's line

set showmatch     " set show matching parenthesis

set sidescroll=1  " scroll by 1 char at a time instead of 1/2 screen width

set smarttab      " insert tabs on the start of a line according to
                  "    shiftwidth, not tabstop
set incsearch     " show search matches as you type

if ! &diff
  " This is disabled by default because, once vim has more than 3 or 4
  " windows open, relaying out the whole screen makes intentionall
  " small windows big again.
  set noequalalways " Don't resize on :split or :close of a window
endif

set formatoptions-=ro  " When wrapping paragraphs, don't end lines
set formatoptions+=1   " When wrapping paragraphs, don't end lines
                       " with 1-letter words (looks stupid)

set path=$PWD/**    " :find files in ./...

autocmd BufEnter,BufNewFile,BufRead * setlocal formatoptions-=ro " an autocommand so C and other plugins don't clobber this setting
autocmd BufEnter,BufNewFile,BufRead * setlocal formatoptions+=1  " an autocommand so C and other plugins don't clobber this setting

set guioptions-=t   " Remove toolbar
set scrolloff=0     " Don't force lines above and below cursor

set switchbuf=usetab,split " usetab: Search for open window or tab first. split: open in place

set virtualedit=block " block: allow selecting rectangles that end in short lines

set nowarn          " Avoid [No write since last change] with :!
set winminwidth=0   " Allow windows to collapse completely
set winminheight=0  " Allow windows to collapse completely
set winwidth=1      " Don't open windows more than one column when selecting
set splitbelow
set splitright

set belloff=esc,wildmode  " esc: quiet <esc> in Normal mode, <wildmode>: quiet cmdline-completion available

set keymodel-=stopsel " Don't let arrow keys exit visual mode

set whichwrap+=<,>,h,l,[,]

" Allow control-leader, so that I don't need to exit TERMINAL MODE before
" swapping tabs, etc.
nmap <C-\> <leader>
imap <C-\> <C-o><leader>
tmap <C-\> <C-\><C-n><leader>

" ^S to Save
map  <silent> <C-s> :wa<CR>
imap <silent> <C-s> <Esc><C-s>

" Indent/dedent in visual mode
vmap <silent> <Tab>   >gv
vmap <silent> <S-Tab> <gv

" Clear highlight on <Esc>, but only in normal mode
if has("nvim")
  map <silent> <Esc> <Esc>:nohl<CR>
  vnoremap <silent> <Esc> <Esc>
endif

" Tabs <leader>-Arrows, Home, etc: move between tabs
map <silent> <leader>!           :tabnew<CR>:term<CR>:startinsert<CR>
map <silent> <leader><Insert>    :tabnew<CR>
map <silent> <leader><Left>      :tabprev<CR>
map <silent> <leader><Right>     :tabnext<CR>
map <silent> <leader><Home>      :tabfirst<CR>
map <silent> <leader><End>       :tablast<CR>

" <F1>: Help for word under cursor or visual selection
map     <silent><expr> <F1>    ":\<C-u>tab help " . expand("<cword>") . "\<CR>"
vmap    <silent><expr> <F1>    ":\<C-u>tab help " . GetVisualSelection() . "\<CR>"

function! GetVisualSelection()
    " Why is this not a built-in Vim script function?!
    let [line_start, column_start] = getpos("'<")[1:2]
    let [line_end, column_end] = getpos("'>")[1:2]
    let lines = getline(line_start, line_end)
    if len(lines) == 0
        return ""
    endif
    let lines[-1] = lines[-1][: column_end - (&selection == 'inclusive' ? 1 : 2)]
    let lines[0] = lines[0][column_start - 1:]
    let s = join(lines, "\n")
    if len(s) == 0
        return ""
    else
        return s
    endif
endfunction

" <F2>: Exit, like <Esc> but works in TERMINAL mode

imap    <silent> <F2> <Esc>l
vmap    <silent> <F2> <Esc><F2>
omap    <silent> <F2> <Esc><F2>
if has("nvim")
    tmap   <silent> <F2> <C-\><C-n>
endif

" <F3>: Next search match.
" <S-F3>: Prev search match.
map     <silent> <F3>  /<CR>
map     <silent> <F13> ?<CR>
nmap    <silent> n     /<CR>
nmap    <silent> N     ?<CR>
imap    <silent> <F3>  <Esc><F3>
imap    <silent> <F13> <Esc><F13>
vmap    <silent> <F3>  <Esc><F3>
vmap    <silent> <F13> <Esc><F13>

cmap    <silent><expr> <F3>  HandleCommandModeF3()
cmap    <silent><expr> <F13> HandleCommandModeF13()

function! HandleCommandModeF3()
    let cmdtype = getcmdtype()
    if cmdtype == '/' || cmdtype == '?'
       return "\<CR>\<F3>"
    endif
endfunction

function! HandleCommandModeF13()
    let cmdtype = getcmdtype()
    if cmdtype == '/' || cmdtype == '?'
       return "\<CR>\<F13>"
    endif
endfunction

" <Alt-F>o: gui-menu-like File->Open emulation, with fuzzy matching
map  <silent> <M-f>o :E<CR>
vmap <silent> <M-f>o <Esc><M-f>o
imap <silent> <M-f>o <Esc><M-f>o
cmap <silent> <M-f>o <Esc><M-f>o

" Open Other related file (Find other files with similar names and different
" extensions easily.
map  <expr> <M-f>C    OpenOtherRelatedFile(".cpp")
map  <expr> <leader>C OpenOtherRelatedFile(".cpp")
map  <expr> <M-f>H    OpenOtherRelatedFile(".h")
map  <expr> <leader>H OpenOtherRelatedFile(".h")
map  <expr> <M-f>I    OpenOtherRelatedFile(".ivcg")
map  <expr> <leader>I OpenOtherRelatedFile(".ivcg")
map  <expr> <M-f>O    OpenOtherRelatedFile("")
map  <expr> <leader>O OpenOtherRelatedFile("")
map  <expr> <M-f>Q    OpenOtherRelatedFile(".qml", "ViewModel")
map  <expr> <leader>Q OpenOtherRelatedFile(".qml", "ViewModel")
map  <expr> <M-f>T    OpenOtherRelatedFile("Tests.cpp")
map  <expr> <leader>T OpenOtherRelatedFile("Tests.cpp")
map  <expr> <M-f>Y    OpenOtherRelatedFile(".yaml")
map  <expr> <leader>Y OpenOtherRelatedFile(".yaml")

function! OpenOtherRelatedFile(ext, ...) abort
    let fn = expand("%:t")
    let new_fn = substitute(fn, '.\zs\.[^.]\+', a:ext, '')
    if a:0 >= 1
        let new_fn = substitute(new_fn, a:1, '', '')
    endif

    let exclusion_prefix = "/"
    if fn == expand("%") " Not in a dir
        let exclusion_prefix = "^"
    endif

    " !...$ excludes files with the current file's name
    return ":E !" . exclusion_prefix . fn . "$ /" . new_fn . "\<CR>"
endfunction

" <leader>r: replace
map     <leader>r :%s/\<<c-R><c-W>\>//g<Left><Left>
vmap    <leader>r "zy:%s/<c-R>z//g<Left><Left>

" <leader>R: windo replace
map     <leader>R :windo %s/\<<c-R><c-W>\>//g<Left><Left>
vmap    <leader>R "zy:windo %s/<c-R>z//g<Left><Left>

" Searching
set noignorecase  " don't ignore case when searching
set nosmartcase   " don't ignore case if search pattern is all lowercase, case-sensitive otherwise

if &diff
    map <leader>H VxnVnx
    map <leader>O VnxknVx
endif

" <F4>: sync with filesystem: load & save changes
map     <silent> <F4> :checktime<CR>:wa<CR>:diffupdate<CR>
imap    <silent> <F4> <Esc><F4>i
vmap    <silent> <F4> <Esc><F4>gv
if has("nvim")
    tmap   <silent> <F4> <C-\><C-n><F4>i
endif

" <C-s>: save current file
map     <silent> <C-s> :checktime<CR>:wa<CR>:diffupdate<CR>
imap    <silent> <C-s> <Esc><C-s>i
vmap    <silent> <C-s> <Esc><C-s>gv
if has("nvim")
    tmap   <silent> <C-s> <C-\><C-n><C-s>i
endif

" <C-S-s>: sync with filesystem: load & save changes
map     <silent> <C-S-s> :checktime<CR>:w<CR>:diffupdate<CR>
imap    <silent> <C-S-s> <Esc><C-S-s>i
vmap    <silent> <C-S-s> <Esc><C-S-s>gv
if has("nvim")
    tmap   <silent> <C-S-s> <C-\><C-n>:%w!
endif

" shift-<F4>: close window
map     <silent> <F14> :close<CR>
imap    <silent> <F14> <Esc><F14>
vmap    <silent> <F14> <Esc><F14>
if has("nvim")
    tmap   <silent> <F14> <C-\><C-n><F14>
endif

" <F5>: Search filesystem for word under cursor
map     <silent> <F5> :exec('!grep -rw --exclude-dir cg "' . expand("<cword>") . '" .')<CR>
imap    <silent> <F5> <Esc><F5>i
vmap    <silent> <F5> :\<C-u>exec('!grep --exclude-dir cg -r "' . GetVisualSelection() . '" .')<CR>
if has("nvim")
    tmap   <silent> <F5> <C-\><C-n><F5>i
endif

map <expr> <F5> ":call GrepInTerm(\'" . expand("<cword>") . "')<CR><C-\><C-n>"

function! DeleteProcessExitedMessage(timer_id)
    setlocal modifiable
    execute '%s/\[Process exited 0\]//'
    execute '%s/\($\n\s*\)\+\%$//'
endfunction

function! OnExitSuppressProcessExitedWith0(job_id, code, event)
    call timer_start(10, 'DeleteProcessExitedMessage')
endfunction

function! GrepInTerm(pattern) abort
    let buf = nvim_create_buf(v:false, v:true)
    let opts = {'relative': 'editor', 'width': 200, 'height': 50, 'col': 10,
        \ 'row': 1, 'anchor': 'NW'}
    let win = nvim_open_win(buf, 0, opts)
    " optional: change highlight, otherwise Pmenu is used
    call nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
    call nvim_set_current_win(win)

    let cmd =  'grep --exclude-dir cg -rw "' . a:pattern . '" *'
    let opt = { 'on_exit': 'OnExitSuppressProcessExitedWith0' }
    call termopen(cmd . ' ; sleep 0.1', opt) " sleep allows neovim to read all output
    let b:term_title = cmd
endfunction

" <S-F5> (<F15>) to list matching files, which is useful prior to opening
" each.
map     <silent> <F15> :exec('!grep -rwl "' . expand("<cword>") . '" .')<CR>
imap    <silent> <F15> <Esc><F15>i
vmap    <silent> <F15> :\<C-u>exec('!grep -rl "' . GetVisualSelection() . '" .')<CR>
if has("nvim")
    tmap   <silent> <F15> <C-\><C-n><F15>i
endif
" <F7>: Open command-line window, like cmd.com's <F7>
map  <F7> :<F7>
vmap <F7> :<F7>
imap <F7> <Esc><F7>
cmap <F7> <C-f>

" <F8>, next error is inspired by Visual Studio
map     <silent> <F8>    :cnext<CR>
lmap    <silent> <F8>    <Esc><F8>
map     <silent> <S-F8>  :cprev<CR>
map     <silent> <F18>   :cprev<CR>
lmap    <silent> <S-F8>  <Esc>:cprev<CR>
lmap    <silent> <F18>   <Esc>:cprev<CR> " <F18> is <S-F8> on my laptop.

if has("nvim")
    tmap   <silent> <F8>    <Esc>:cnext<CR>
    tmap   <silent> <S-F8>  <Esc>:cprev<CR>
endif

" Show syntax stack (developer hack, easily moved)
function! SynStack()
  if !exists("*synstack")
      return
  endif
  return "[".join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'),",")."]"
endfunc

function! SynGroup()
    let l:s = synID(line('.'), col('.'), 1)
    return "[" . synIDattr(l:s, 'name') . ' -> ' . synIDattr(synIDtrans(l:s), 'name') . "]"
endfun

"map    <silent> <F10>   :echo "hi<".synIDattr(synID(line("."),col("."),1),"name").'> trans<'.synIDattr(synID(line("."),col("."),0),"name")."> lo<".synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")."> stack:".SynStack() . " " . SynGroup()<CR>


" <F10> Full screen the visual selection
" <F20> (<S-F10>): Narrow back.
" The extra <Esc> after the tab new is when coming from vterm's terminal
" vmap   <silent> <F10> :<C-u><F10>
" map    <silent> <F10> :tabclose<CR>

" <F11>: "full screen"
map    <silent> <F11> :tab split \| setlocal laststatus=1<CR>100zH
imap   <silent> <F11> <C-o><F11>
vmap   <silent> <F11> <Esc><Fll>gv
if has("nvim")
    tmap   <silent> <F11> <C-\><C-n><F11>
endif

" <F12>: bottom window (usually my terminal window / previous window toggle)
" Trimming the scrollback like this prevents the terminal from scrolling
" when not scrolled all the way down. Until 50,000 more lines accumulate.
map    <silent> <F12> <C-w>b<C-\><C-n>:set scrollback=50000<CR>:set scrollback=100000<CR>
imap   <silent> <F12> <Esc><F12>
vmap   <silent> <F12> <Esc><F12>

function! GetChar(at) abort
    let l:pos = a:at
    if type(l:pos) == 1 " 1: string
        let l:pos = getpos(l:pos)
    endif

    let l:line = getline(l:pos[1])
    let l:index = l:pos[2] - 1

    if l:index < 0 || l:index >= strwidth(l:line)
        return "\n"
    end

    return strcharpart(line, l:index, 1)
endfunction

function! CharType(c) abort
    if a:c =~# '\w'
      return 'word'
    elseif a:c =~# '[(){}"''[\]]'
      return 'pair'
    elseif a:c == '\n'
      return 'newline'
    else
      return 'other'
    end
endfunction

function! GetLineTextObjectExpr(i_or_a) abort
  let l:vpos = getpos('v')
  let l:cpos = getpos('.')

  let l:is_reversed = ComparePositions(l:vpos, l:cpos) > 0
  echom col('$')
  if !l:is_reversed
    if a:i_or_a == 'a' || col('$') == 1
      return 'o0o$'
    else
      return 'o0o$h'
    end
  else
    if a:i_or_a == 'a' || col('$') == 1
      return '0o$o'
    else
      return '0o$ho'
    end
  endif
endfunction

vnoremap <expr> il GetLineTextObjectExpr('i')
vnoremap <expr> al GetLineTextObjectExpr('a')

"let s:visual_stack       = []
"let s:visual_stack_index = 0
"
"function! InitVisualRangeStack() abort
"  let s:visual_stack       = []
"  let s:visual_stack_index = 0
"endfunction
"
"function! PushVisualRange() abort
"  let s:visual_stack = s:visual_stack[:s:visual_stack_index] + [ [ getpos('v'), getpos('.') ] ]
"  let s:visual_stack_index += 1
"endfunction
"
"function! StartVisualExpr() abort
"  call InitVisualRangeStack()
"
"  let l:c = GetChar('.')
"
"  let l:t = CharType(l:c)
"
"  if     l:t == 'word'
"    return 'viw'
"  elseif l:t == 'pair'
"    return 'v%'
"  else
"    return 'viW'
"  endif
"
"endfunction
"
"function! ComparePositions(p0, p1) abort
"  if a:p0[1] < a:p1[1]
"    return -1
"  endif
"
"  if a:p0[1] > a:p1[1]
"    return 1
"  endif
"
"  if a:p0[2] < a:p1[2]
"    return -1
"  endif
"
"  if a:p0[2] > a:p1[2]
"    return  1
"  endif
"
"  return 0
"endfunction
"
"lua package.loaded.text_objects = nil; -- debug only
"lua require("text_objects")
"
"function! MapQuotesOnLine(type) abort
"  let l:pos = getpos('.')
"  let l:line = getline(l:pos[1])
"  let l:stack = []
"  let l:region = 0
"  for l:c in split(l:line, '\zs')
"  endfor
"endfunction
"
"function! GetTextObject(type) abort
"  if mode() == 'n'
"    normal v
"  endif
"
"  let l:vpos = getpos('v')
"  let l:cpos = getpos('.')
"
"  let l:is_reversed = ComparePositions(l:vpos, l:cpos) > 0
"  if l:is_reversed
"    normal o
"    let l:vpos = getpos('v')
"    let l:cpos = getpos('.')
"  endif
"
"  let l:is_one_line = l:vpos[1] == l:cpos[1]
"
"  if a:type == '"' || a:type == "'"
"      if !l:is_one_line
"        return []
"      endif
"
"      let l:m = MapQuotesOnLine(a:type)
"  endif
"
"endfunction
"
"function! GetVisualModeText() abort
"  let save_clipboard = &clipboard
"  set clipboard= " Avoid clobbering the selection and clipboard registers.
"  let save_reg = getreg('"')
"  let save_regmode = getregtype('"')
"  silent normal! ygv
"  let res = getreg('"')
"  call setreg('"', save_reg, save_regmode)
"  let &clipboard = save_clipboard
"  return res
"endfunction
"
"function! GrowVisual() abort
"  normal gv
"
"  if len(s:visual_stack) == 0
"    call PushVisualRange()
"  endif
"
"  "echom "======================="
"
"  let l:vpos = getpos('v')
"  let l:cpos = getpos('.')
"
"  let l:is_reversed = ComparePositions(l:vpos, l:cpos) > 0
"  if l:is_reversed
"    normal o
"    let l:vpos = getpos('v')
"    let l:cpos = getpos('.')
"  endif
"
"  "echom " =" join(l:vpos,':') join(l:cpos,':')
"
"  let l:vp = l:vpos
"  let l:cp = l:cpos
"
"  let l:found = 0
"
"  for l:o in [ 'i(', 'a(', 'i{', 'a{', 'i[', 'a[', 'i''', 'i"']
"    if l:o == 'i'''
"      call setpos(".", l:vp)
"      normal o
"      call setpos(".", l:cp)
"
"      let l:text = GetVisualModeText()
"      if match(l:text, '''') >= 0
"          continue
"      endif
"    endif
"
"    "echom " "
"    call setpos(".", l:vpos)
"    normal o
"    call setpos(".", l:cpos)
"
"    exe "normal " . l:o
"
"    let l:v = getpos("v")
"    let l:c = getpos(".")
"
"    "echom l:o . '?' join(l:v, ':') join(l:c, ':') ComparePositions(l:v, l:vpos) ComparePositions(l:c, l:cpos) ComparePositions(l:v, l:vp) ComparePositions(l:c, l:cp)
"    if    (
"        \      ComparePositions(l:v, l:vpos) < 0
"        \   || ComparePositions(l:c, l:cpos) > 0
"        \ )
"        \ && (
"        \    !l:found
"        \    || (
"        \         ComparePositions(l:v, l:vp) >  0
"        \      && ComparePositions(l:c, l:cp) <  0
"        \    )
"        \ )
"      let l:vp = l:v
"      let l:cp = l:c
"      let l:found = 1
"      "echom l:o . '=' join(l:vp, ':') join(l:cp, ':')
"    endif
"  endfor
"
"  if !l:found " Expand to line
"    if l:vp[2] > 1
"      let l:found = 1
"      let l:vp[2] = 1
"    endif
"    let l:cend = col("$")
"    if l:cp[2] < l:cend
"      let l:found = 1
"      let l:cp[2] = l:cend
"    endif
"  endif
"
"  call setpos(".", l:vp)
"  normal o
"  call setpos(".", l:cp)
"
"  if l:is_reversed
"    normal o
"  endif
"
"  if l:found
"    call PushVisualRange()
"  endif
"
"  "echom join(getpos("v"), ':') join(getpos("."), ':')
"endfunction
"
"function! ShrinkVisual() abort
"  normal gv
"  if s:visual_stack_index > 0
"    let s:visual_stack_index -= 1
"    call setpos(".", s:visual_stack[s:visual_stack_index][0])
"    normal o
"    call setpos(".", s:visual_stack[s:visual_stack_index][1])
"  end
"endfunction
"
"function! GrowVisualLeft() abort
"  normal gv
"
"  if len(s:visual_stack) == 0
"    call PushVisualRange()
"  endif
"
"  let l:v = getpos("v")
"  let l:c = getpos(".")
"  if ComparePositions(l:v, l:c) < 0
"    normal o
"  endif
"
"  normal b
"
"  call PushVisualRange()
"endfunction
"
"function! StartVisualGrowLeftExpr() abort
"  call InitVisualRangeStack()
"  return "vb"
"endfunction
"
"function! StartVisualGrowRightExpr() abort
"  call InitVisualRangeStack()
"  return "vw"
"endfunction
"
"function! GrowVisualRight() abort
"  normal gv
"
"  if len(s:visual_stack) == 0
"    call PushVisualRange()
"  endif
"
"  let l:v = getpos("v")
"  let l:c = getpos(".")
"  if ComparePositions(l:v, l:c) > 0
"    normal o
"  endif
"
"  normal w
"
"  call PushVisualRange()
"endfunction
"
"nnoremap <expr>   + StartVisualExpr()
"nnoremap <expr>   ( StartVisualGrowLeftExpr()
"nnoremap <expr>   ) StartVisualGrowRightExpr()
"
"vnoremap <silent> + :call GrowVisual()<CR>
"vnoremap <silent> v :call GrowVisual()<CR>
"vnoremap <silent> _ :call ShrinkVisual()<CR>
"vnoremap <silent> ( :call GrowVisualLeft()<CR>
"vnoremap <silent> ) :call GrowVisualRight()<CR>
"
"nnoremap <expr>   <C-Up>    StartVisualExpr()
"nnoremap <expr>   <C-Left>  StartVisualGrowLeftExpr()
"nnoremap <expr>   <C-Right> StartVisualGrowRightExpr()
"vnoremap <silent> <C-Up>    :call GrowVisual()<CR>
"vnoremap <silent> <C-Down>  :call ShrinkVisual()<CR>
"vnoremap <silent> <C-Left>  :call GrowVisualLeft()<CR>
"vnoremap <silent> <C-Right> :call GrowVisualRight()<CR>
"
"nnoremap <expr>   <C-ScrollWheelUp>   StartVisualExpr()
"vnoremap <silent> <C-ScrollWheelUp>   :call GrowVisual()<CR>
"vnoremap <silent> <C-ScrollWheelDown> :call ShrinkVisual()<CR>
"
" [a and ]a are under development and not yet right, propably to be replaced
" with a treesitter-based approach.
" Syntax region text object "ia" and "aa" (inspired by SyntaxMotion.vim)
"
"function! MoveCursor(dir)
"  let l:start_pos = getpos('.')
"  if a:dir == 'h'
"    normal! h
"  else
"    normal! l
"  end
"  return getpos('.') != l:start_pos
"endfunction
"
"function! SyntaxMotion(dir, mode, count)
"  if a:mode == 'v'
"    normal gv
"  end
"
"  let l:count = a:count
"  if l:count == 0
"      let l:count = 1
"  endif
"
"  let l:whichwrap = split(&whichwrap . ",h,l", ",")
"  let l:whichwrap = filter(copy(l:whichwrap), 'index(l:whichwrap, v:val, v:key+1) == -1')
"  let &whichwrap = join(l:whichwrap,",")
"
"  while l:count > 0
"    let l:syn_stack_0 = synstack(line('.'), col('.'))
"
"    while 1
"      let l:save_cursor = getpos(".")
"
"      call MoveCursor(a:dir)
"
"      if getpos('.') == l:save_cursor
"          break
"      end
"
"      let l:syn_stack_1 = synstack(line('.'), col('.'))
"
"      if l:syn_stack_1 != l:syn_stack_0
"        call setpos('.', l:save_cursor)
"        break
"      endif
"    endwhile
"
"    let l:count = l:count - 1
"  endwhile
"
"endfunction
"
"nnoremap <silent> ]a l:call SyntaxMotion('l', 'n', v:count)<CR>
"vnoremap <silent> ]a l:call SyntaxMotion('l', 'v', v:count)<CR>
"nnoremap <silent> [a h:call SyntaxMotion('h', 'n', v:count)<CR>
"vnoremap <silent> [a h:call SyntaxMotion('h', 'v', v:count)<CR>
"
"vnoremap <silent> ia :<c-u>call SelectSyntaxRegion('i')<CR>
"vnoremap <silent> aa :<c-u>call SelectSyntaxRegion('a')<CR>
"onoremap <silent> ia :normal via<CR>
"onoremap <silent> aa :normal vaa<CR>
"
" submodes

let g:submode_timeout          = 0
let g:submode_keep_leaving_key = 1

" Navigation axis ideas (todos?)
"     undo tree tips ("leaves"); see undotree() and its alt entries
"     file history of current window (or buffer); see :getjumplist(); add keys to jumps submode, like C-Left, C-Right?
"
"     NOTE: gg{ and gg} shouldn't map to <Left> and <Right>, are they a nav mode?
"
"    [ name           [entry mappings     ]  [submode mappings  ], [replacements     ]
"    [                [left,  right, addtl]  [left,    right    ], [left      right  ]
let l:nav_axes = [
    \[ 'changes',     ['gg;', 'gg,', 'ggc'], [';',     ',',     ], ['g;',    'g,'   ] ],
    \[ 'jumps',       [              'ggj'], ['<C-o>', '<C-i>', ], ['<C-o>', '<C-i>'] ],
    \[ 'undo',        [              'ggu'], ['u',     'r',     ], ['u',     '<C-r>'] ],
    \[ 'undo_time',   ['gg-', 'gg+', 'ggU'], ['-',     '+',     ], ['g-',    'g+'   ] ],
    \[ 'braces',      ['gg{', 'gg}'       ], ['{',     '}',     ], ['[{',    ']}'   ] ],
    \
    \[ 'window',      [       '<C-w><C-w>'], [                  ], [                ] ],
    \[ 'window',      [              'ggw'], ['',      '',      ], [                ],
    \   ['E',            ':E '                         ],
    \   ['H',            '<C-w>H'                      ],
    \   ['J',            '<C-w>J'                      ],
    \   ['K',            '<C-w>K'                      ],
    \   ['L',            '<C-w>L'                      ],
    \   ['R',            '<C-w>R'                      ],
    \   ['W',            '<C-w>W'                      ],
    \   ['b', '<End>',   '<C-w>b'                      ],
    \   ['c', '<End>',   '<C-w>c'                      ],
    \   ['e',            ':e '                         ],
    \   ['h', '<Left>',  '<C-w>h'                      ],
    \   ['j', '<Down>',  '<C-w>j'                      ],
    \   ['k', '<Up>',    '<C-w>k'                      ],
    \   ['l', '<Right>', '<C-w>l'                      ],
    \   ['n',            '<C-w>n'                      ],
    \   ['p',            '<C-w>p'                      ],
    \   ['r',            '<C-w>r'                      ],
    \   ['s',            '<C-w>s'                      ],
    \   ['t', '<Home>',  '<C-w>t'                      ],
    \   ['v',            '<C-w>v'                      ],
    \   ['w',            '<C-w>w'                      ],
    \   ['x',            '<C-w>x'                      ],
    \   ['<',            '<C-w><'                      ],
    \   ['>',            '<C-w>>'                      ],
    \   ['+',            '<C-w>+'                      ],
    \   ['-',            '<C-w>-'                      ],
    \   ['<Bar>',        '<C-w><Bar>'                  ],
    \   ['_',            '<C-w>_'                      ],
    \   ['=',            '<C-w>='                      ],
    \   ['!',            '<C-w>!'                      ],
    \   ['<C-c>',        ':call MarkWindow("c")<CR>'   ],
    \   ['<C-e>',        '<C-e>'                       ],
    \   ['<C-n>',        ':new<CR>'                    ],
    \   ['<C-o>',        ['x', ':call OpenFile()<CR>'] ],
    \   ['<C-v>',        ':call PasteWindow()<CR>'     ],
    \   ['<C-x>',        ':call MarkWindow("x")<CR>'   ],
    \   ['<C-y>',        '<C-y>'                       ],
    \   ['<C-Home>',     ':tabfirst<CR>'               ],
    \   ['<C-PageUp>',   ':tabprev<CR>'                ],
    \   ['<C-PageDown>', ':tabnext<CR>'                ],
    \   ['<C-End>',      ':tablast<CR>'                ],
    \],
\]

for l:axis in l:nav_axes
    let l:name            = l:axis[0]
    let l:entry_sequences = l:axis[1]
    let l:lhs_sequences   = l:axis[2]
    let l:rhs_sequences   = l:axis[3]

    function! s:SM_enter(lhs, rhs) closure
        return submode#enter_with(l:name, 'nv', '', a:lhs, a:rhs)
    endfunction

    function! s:SM_map(options, lhs, rhs) closure
        return submode#map(l:name, 'nv', a:options, a:lhs, a:rhs)
    endfunction

    let l:i = 0
    while i < len(l:entry_sequences)
        if len(l:entry_sequences) == 1 || i >= len(l:entry_sequences) || i >= len(l:rhs_sequences)
            call s:SM_enter(l:entry_sequences[i], '<Nop>')
        else
            call s:SM_enter(l:entry_sequences[i], l:rhs_sequences[i])
        endif
        let l:i = l:i + 1
    endwhile

    let l:i = 0
    while i < len(l:lhs_sequences)
        if len(l:lhs_sequences[i]) > 0
            call s:SM_map('', l:lhs_sequences[i], l:rhs_sequences[i % len(l:rhs_sequences)])
        end
        let l:i = l:i + 1
    endwhile

    if len(l:rhs_sequences) >= 2
        call s:SM_map('', 'h',       l:rhs_sequences[0])
        call s:SM_map('', '<Left>',  l:rhs_sequences[0])
        call s:SM_map('', 'l',       l:rhs_sequences[1])
        call s:SM_map('', '<Right>', l:rhs_sequences[1])
    endif

    for l:mappings in l:axis[4:]
        let l:rhs = l:mappings[-1]
        let l:options = ''
        if type(l:rhs) == v:t_list
            let l:options = l:rhs[0]
            let l:rhs     = l:rhs[1]
        endif
        for l:lhs in l:mappings[0:len(l:mappings)-2]
            call s:SM_map(l:options, l:lhs, l:rhs)
        endfor
    endfor

endfor

function! MarkWindow(paste_mode) abort  " See window submode's m mapping above
    let s:marked_window = [ win_getid(), bufnr() ]
    let s:paste_mode = a:paste_mode
endfunction

function! HandleOpenFileTimer(timer) abort
    call E_command()
endfunction

function! OpenFile() abort
    call timer_start(1, "HandleOpenFileTimer")
endfunction

function! PasteWindow() abort
    if !exists('s:marked_window')
        echom "No marked window"
        return
    endif

    call execute("buf " . s:marked_window[1])

    if s:paste_mode == "x"
        let l:old_win_id = s:marked_window[0]
        let l:new_win_id = win_getid()

        call win_gotoid(l:old_win_id)
        call execute("wincmd c")
        call win_gotoid(l:new_win_id)
    endif
endfunction

" :terminal navigation
if has("nvim")
    " Make ^W work in terminal mode so window navigation works.
    " Downside is if any programs in a terminal need to see ^W.
    tnoremap <C-w> <C-\><C-n><C-W>
    tnoremap <S-Esc> <C-\><C-n>

    function! HandleTermEnter()
        if exists("b:term_was_in_term_mode") && b:term_was_in_term_mode
            execute ":startinsert"
        endif
    endfunc

    " Enter terminal mode when navigating to a terminal window
    " via the keyboard.
    autocmd! BufWinEnter,WinEnter,BufEnter term://*
    " TODO: autocmd BufWinEnter,WinEnter,BufEnter term://* call HandleTermEnter()
    autocmd BufWinEnter,WinEnter,BufEnter term://* map <C-c> a<C-c> | vmap <C-c> <Esc><C-c>

    if exists('+winhighlight')
        function! s:configure_winhighlight()
            let ft = &filetype
            let bt = &buftype
            " Check white/blacklist.
            if index(['dirvish'], ft) == -1
                \ && (index(['nofile', 'nowrite', 'acwrite', 'quickfix', 'help'], bt) != -1
                \     || index(['startify'], ft) != -1)
                set winhighlight=Normal:FocusedNormal,NormalNC:FocusedNormal,EndOfBuffer:FocusedEndOfBuffer
                " echom "normal" winnr() &winhighlight 'ft:'.&ft 'bt:'.&bt
            else
                set winhighlight=Normal:FocusedNormal,NormalNC:UnfocusedNormal,EndOfBuffer:UnfocusedEndOfBuffer
                " echom "inactive" winnr() &winhighlight 'ft:'.&ft 'bt:'.&bt
            endif
        endfunction

        augroup inactive_win
            au!
            au ColorScheme          * hi link InactiveWin ColorColumn | hi link NormalWin Normal
            au FileType,BufWinEnter * call s:configure_winhighlight()
            au WinEnter             * setlocal winhl-=WinSeparator:WinSeparatorNC
            au WinLeave             * setlocal winhl+=WinSeparator:WinSeparatorNC
            au FocusGained          * hi link NormalWin Normal
            au FocusLost            * hi link NormalWin InactiveWin
        augroup END

    endif
endif

endfunction

if !exists("g:VimEnter_Initialized") || g:VimEnter_Initialized
    call VimEnter_Initialize() " Allow source .vimrc to work
end

autocmd FileType perl :setlocal iskeyword-=:

" lua require("plugins/vim-growmode")

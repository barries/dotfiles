"dein Scripts-----------------------------
if &compatible
 set nocompatible               " Be iMproved
endif

set runtimepath+=/home/barries/.vim/bundle/repos/github.com/Shougo/dein.vim

if dein#load_state('/home/barries/.vim/bundle/')
  call dein#begin('/home/barries/.vim/bundle/')

  " Let dein manage dein
  call dein#add(expand('/home/barries/.vim/bundle/repos/github.com/Shougo/dein.vim'))

  " Add or remove your plugins here:
  " Removed for now (barries): call dein#add('Shougo/neosnippet.vim')
  " Removed for now (barries): call dein#add('Shougo/neosnippet-snippets')

  " You can specify revision/branch/tag.
  " Removed for now (barries): call dein#add('Shougo/deol.nvim', { 'rev': 'a1b5108fd' })
  "
  " To force an update :call dein#update()
  call dein#add('danro/rename.vim')
  call dein#add('godlygeek/tabular')
  call dein#add('inkarkat/vim-ingo-library')
  call dein#add('inkarkat/vim-mark') " sets maps on \r *after* .vimrc exit, see VimEnter_Initialize()
  "call dein#add('vim-scripts/Align')

  " Required:
  call dein#end()
  call dein#save_state()
endif

"source plugin/AnsiEsc.vim

filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
"if dein#check_install()
"  call dein#install()
"endif

"End dein Scripts-------------------------

" Appearance
if !has("nvim")
    set ttymouse=xterm2 " Allow mouse to drag splits
    set t_Co=256
    let $GIT_EDITOR = 'nvr -cc split --remote-wait'
endif

set runtimepath^=~barries/.vim

colorscheme barries
syn on

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
endfunc

function! E_command(...)
    let opts = {
        \ 'options': ['--multi', '--select-1', '-i', '--tiebreak=end,length'],
        \ 'window': 'vertical aboveleft 100new'
    \ }

    let args = deepcopy(a:000)

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

    call fzf#run(fzf#wrap('E', opts))
endfunc

command! -nargs=* -complete=file_in_path E     call E_command(<f-args>)

command! -nargs=* -range                 Align call Tabularize(<f-args>)

autocmd VimEnter * call VimEnter_Initialize()

" Called after plugins are loaded, which is needed to override mapping set by plugins (like vim-mark's)
function! VimEnter_Initialize()

let g:VimEnter_Initialize = 1

" cabbrev <expr> e (getcmdtype()==':' && getcmdpos()<=2 ? 'E' : 'e')
cmap <expr> <leader><Tab> CmdLineTab()

nmap <C-\> <leader>

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

function! ClearRegs()
    let regs=split('abcdefghijklmnopqrstuvwxyz0123456789/-"', '\zs')
    for r in regs
        call setreg(r, [], 'c')
    endfor
endfunction

command! ClearRegs :call ClearRegs()

" Disabled: this overrides the foreground in all rows set cursorcolumn
" Disabled: this overrides the foreground in all rows set cursorline

" Not implemnted yest in nvim: au OptionSet diff let &cul=v:option_new
"
augroup MyCursorLine
  au!
"  au FilterWritePost * if  &diff | let &cursorline=1 | let &cursorcolumn=1 | endif
"  au BufEnter        * if !&diff | let &cursorline=0 | let &cursorcolumn=0 | endif
augroup end

if &diff
    set cursorline
end

set foldopen-=hor

" Status Line Appearance

set fillchars=vert:\ ,fold:+,diff:\     " Remove pipe character from vertical splits, uses ' ' for deleted line in diff output

function! GetStatusLineRHS()
    return "%=%9*%l,%v%*\ %p%%"                      " %=: switch to right; %9:*: User9 color; %l: line#; %v: virt. col number; %p: percent
endfunction

set statusline=%f\                      " %f: Filename
set statusline+=%4*%m%5*%r%w%h%q%*      " %4*: User4 color; %m: modified; %5*: User5Color; %r: readonlyflag; %w: preview flag%h: help; %q: quickfix list; %*: revert color
let &statusline=&statusline . GetStatusLineRHS()

if has("nvim")
    autocmd TermOpen * let &l:statusline="%{b:term_title}" . GetStatusLineRHS() | set winfixheight | set nonu | set norelativenumber

    map     <silent> <C-W>! :split<CR><C-W><S-J>:term<CR>:startinsert<CR>
    imap    <silent> <C-W>! <Esc><C-W>!
    vmap    <silent> <C-W>! <Esc><C-W>!
    omap    <silent> <C-W>! <Esc><C-W>!

end

if has("nvim")
    set inccommand=nosplit
endif

" highlight tabs and trailing whitespace, put $ for extending offscreen
set list
set listchars=tab:\ \ ,trail:.,extends:>,precedes:<,nbsp:.

" Display unprintables as <00> hex codes rather than ^@ control codes
set display+=uhex

" Display partial last line
set display+=lastline

" Can't redefing a function that a timer ever used, apparently.
if !exists("g:timer")
    function! MyChecktime(timer)
        try
            checktime
        endtry
    endfunction

    "let g:timer = timer_start(1000, 'MyChecktime', {'repeat': -1})
endif

"set colorcolumn=81 " colorize column 81
set hlsearch       " highlight search terms

" Highlight all instances of word under cursor, when idle.
" Useful when studying strange source code.
" Type z/ to toggle highlighting on/off.
nnoremap z/ :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=4000
    echo 'Highlight current word: off'
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold  * normal :Mark\ <C-r><C-w>
      au CursorMoved * normal :MarkClear
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction

" State files
set dir=~/tmp/vim//
set bdir=~/tmp/vim//
set undodir=~/tmp/vim//
set undofile    " Create undo files so you can undo past file close (>= 7.3)

"set spell
set spellfile=~/.vim/spellfile.en.add

set mouse=a

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

set noequalalways " Don't resize on :split or :close of a window

set formatoptions+=1  " When wrapping paragraphs, don't end lines
                      " with 1-letter words (looks stupid)
set path=$PWD/**    " :find files in ./...

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

set keymodel-=stopsel " Don't let arrow keys exit visual mode

set whichwrap+=<,>,h,l,[,]

" ^E to enter command line mode (like the micro editor)
imap <C-e> <C-o>:

" Allow control-leader, so that I don't need to exit TERMINAL MODE before
" swapping tabs, etc.
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
map     <silent> <F3>  n
map     <silent> <F13> N
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
map  <expr> <M-f>O OpenOtherRelatedFile("")
map  <expr> <M-f>C OpenOtherRelatedFile(".cpp")
map  <expr> <M-f>H OpenOtherRelatedFile(".h")
map  <expr> <M-f>I OpenOtherRelatedFile(".ivcg")
map  <expr> <M-f>T OpenOtherRelatedFile("Tests.cpp")

function! OpenOtherRelatedFile(ext) abort
    let fn = expand("%:t")
    let new_fn = substitute(fn, '.\zs\.[^.]\+', a:ext, '')

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

" <leader>w: select window by name
map     <expr> <leader>w SelectWindowByName()

" Searching
set noignorecase  " don't ignore case when searching
set nosmartcase   " don't ignore case if search pattern is all lowercase, case-sensitive otherwise

if &diff
    map <leader>H VxnVnx
    map <leader>O VnxknVx
endif

function! SelectWindowByName()
    let pattern = input('Window? ')
    let winnr = bufwinnr(pattern)
    if winnr <= 0
        redraw
        echoerr('Window ' . pattern . ' not found')
    else
        exe winnr . "wincmd w"
    endif
endfunction

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
map     <silent> <F5> :exec('!grep -rw "' . expand("<cword>") . '" .')<CR>
imap    <silent> <F5> <Esc><F5>i
vmap    <silent> <F5> :\<C-u>exec('!grep -r "' . GetVisualSelection() . '" .')<CR>
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

    let cmd =  'grep -rw "' . a:pattern . '" *'
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

" <F9>: move to previous window. I often use <F2> to exit terminal mode
" and the next move is usually to move to the previous window.
map  <F9> <C-w>p
vmap <F9> <Esc><F9>
if has("nvim")
    tmap   <silent> <F9>    <F2><F9>
endif

" Show syntax stack (developer hack, easily moved)
" function! SynStack()
"   if !exists("*synstack")
"       return
"   endif
"   return "[".join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'),",")."]"
" endfunc
"
" map    <silent> <TBD>   :echo "hi<".synIDattr(synID(line("."),col("."),1),"name").'> trans<'.synIDattr(synID(line("."),col("."),0),"name")."> lo<".synIDattr(synIDtrans(synID(line("."),col("."),1)),"name")."> stack:".SynStack()<CR>


" <F10> Full screen the visual selection
" <F20> (<S-F10>): Narrow back.
" The extra <Esc> after the tab new is when coming from vterm's terminal
vmap   <silent> <F10> :<C-u><F10>
map    <silent> <F10> :tabclose<CR>

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
map    <silent> <F12> <C-w>b<C-\><C-n>999<C-w>h<C-\><C-n>:set scrollback=50000<CR>:set scrollback=100000<CR>
imap   <silent> <F12> <Esc><F12>
vmap   <silent> <F12> <Esc><F12>

function! MoveCursor(dir)
  let l:start_pos = getpos('.')
  if a:dir == 'h'
    normal! h
  else
    normal! l
  end
  return getpos('.') != l:start_pos
endfunction

" Syntax region text object "ia" and "aa" (inspired by SyntaxMotion.vim)
function! SyntaxMotion(dir, mode, count)
  if a:mode == 'v'
    normal gv
  end

  let l:count = a:count
  if l:count == 0
      let l:count = 1
  endif

  let l:whichwrap = split(&whichwrap . ",h,l", ",")
  let l:whichwrap = filter(copy(l:whichwrap), 'index(l:whichwrap, v:val, v:key+1) == -1')
  let &whichwrap = join(l:whichwrap,",")

  while l:count > 0
    let l:syn_stack_0 = synstack(line('.'), col('.'))

    while 1
      let l:save_cursor = getpos(".")

      call MoveCursor(a:dir)

      if getpos('.') == l:save_cursor
          break
      end

      let l:syn_stack_1 = synstack(line('.'), col('.'))

      if l:syn_stack_1 != l:syn_stack_0
        call setpos('.', l:save_cursor)
        break
      endif
    endwhile

    let l:count = l:count - 1
  endwhile

endfunction

function! GetChar(at) abort
  return matchstr(getline(a:at), '\%'.col(a:at).'c.')
endfunction

function! MoveCursorOverParensToo(dir)
  if stridx(a:dir == 'l' ? "([{" : ")]}", GetChar('.')) >= 0
    let l:start_pos = getpos('.')
    normal! %
    return getpos('.') != l:start_pos
  else
    return MoveCursor(a:dir)
  endif
endfunction

function! CharPriority(end, c) abort
    if     match(a:c, "[[:lower:][:upper:]_0-9]") >= 0
        return 100
    elseif a:c == "+" || a:c == "-"
        return  89
    elseif a:c == "*" || a:c == "/" || a:c == "%"
        return  88
    elseif a:c == "&" || a:c == "|" || a:c == "^" || a:c == "~"
        return  87
    elseif a:c == "=" || a:c == "!"
        return  80
    elseif a:c == "'"
        return  70
    elseif a:c == "\""
        return  60
    elseif a:c == ":"
        return  50
    elseif a:c == "."
        return  50
    elseif a:c == ","
        return  50
    elseif stridx("]})", a:c) >= 0 && a:end == 'h'
        return  40
    elseif stridx("([{", a:c) >= 0 && a:end == 'l'
        return  40
    elseif a:c == ";"
        return  10
    else
        if a:c == "" || match(a:c, "[[:space:]]") >= 0
            return 1
        endif
        return 0
    endif
endfunction

function! Grow(start_pos, dir) abort
  call setpos('.', a:start_pos)
  let l:pos = a:start_pos
  let l:p0 = CharPriority(a:dir, GetChar('.'))

  while MoveCursor(a:dir)
    let l:c = GetChar('.')
    let l:p1 = CharPriority(a:dir, l:c)
    if l:p1 == l:p0 && stridx("({[]})", l:c) < 0
      let l:pos = getpos('.')
      else
        call setpos('.', pos)
        break
    endif
  endwhile

  return l:pos != a:start_pos
endfunction

function! GrowVisualSelection(v_or_n, h_l_or_b) abort
  let l:save_cursor = getpos(".")

  if a:v_or_n == 'n'
    let l:start_char = GetChar(".")
    let l:start_pos  = l:save_cursor
    let l:end_char   = l:start_char
    let l:end_pos    = l:save_cursor
  else
    normal gv
    let l:start_char = GetChar("'<")
    let l:start_pos  = getpos( "'<")
    let l:end_char   = GetChar("'>")
    let l:end_pos    = getpos( "'>")
    normal v
  endif

  let l:h_priority = CharPriority('h', l:start_char)
  let l:l_priority = CharPriority('l', l:end_char  )

  let l:grew = 0

  let l:try_grow_h = a:h_l_or_b != 'l'
  let l:try_grow_l = a:h_l_or_b != 'h'

  let l:grow_left  = 0
  let l:grow_right = 0

  " Expand to include all same-priority chars
  if l:try_grow_h && Grow(l:start_pos, 'h')
    let l:start_pos = getpos('.')
    let l:grew = 1
    let l:c = GetChar('.')
    if stridx(")}]", l:c) >= 0
      normal! %
      let l:start_pos = getpos('.')
    elseif stridx("({[", l:c) >= 0
      normal! %
      let l:end_pos = getpos('.')
    endif
  endif

  if l:try_grow_l && Grow(l:end_pos, 'l')
    let l:end_pos = getpos('.')
    let l:grew = 1
    let l:c = GetChar('.')
    if stridx("({[", l:c) >= 0
      normal! %
      let l:end_pos = getpos('.')
    elseif stridx(")}]", l:c) >= 0
      normal! %
      let l:start_pos = getpos('.')
    endif
  endif

  " Expand requested end or end with higher priority char to include those chars
  if !l:grew
    let l:h_pri = -1
    if l:try_grow_h
        call setpos('.', l:start_pos)
        if MoveCursor('h')
            let l:h_pos = getpos('.')
            let l:h_pri = CharPriority('h', GetChar('.'))
        end
    end

    let l:l_pri = -1
    if l:try_grow_l
        call setpos('.', l:end_pos)
        if MoveCursor('l')
            let l:l_pos = getpos('.')
            let l:l_pri = CharPriority('l', GetChar('.'))
        end
    end

    if l:h_pri >= 0 || l:l_pri >= 0

        if l:h_pri >= l:l_pri
            call Grow(l:h_pos, 'h')
            let l:start_pos = getpos('.')
            let l:c = GetChar('.')
            if stridx(")}]", l:c) >= 0
              normal! %
              let l:start_pos = getpos('.')
            elseif stridx("({[", l:c) >= 0
              normal! %
              let l:end_pos = getpos('.')
            endif
        endif

        if l:h_pri <= l:l_pri
            call Grow(l:l_pos, 'l')
            let l:end_pos = getpos('.')
            let l:c = GetChar('.')
            if stridx("({[", l:c) >= 0
              normal! %
              let l:end_pos = getpos('.')
            elseif stridx(")}]", l:c) >= 0
              normal! %
               let l:start_pos = getpos('.')
            endif
        endif

    endif

  endif

  call setpos('.', l:start_pos)
  normal v
  call setpos('.', l:end_pos)
  if a:h_l_or_b == 'h'
    normal o
  end

endfunction

function! SelectSyntaxRegion(i_or_a)

  normal gv
  let l:save_cursor = getpos(".")
  let l:v_start_pos = getpos("'<")
  let l:v_end_pos   = getpos("'>")
  normal v

  " != l:v_end_pos instead of == l:v_start_pos: place cursor at end when
  " visual selection is one char long.
  let l:is_at_start = l:save_cursor != l:v_end_pos

  let l:is_big_region = l:v_end_pos != l:v_start_pos

  let l:grow_both_ends = a:i_or_a ==# 'a'

  call setpos('.', l:v_start_pos)
  if (l:is_big_region && l:is_at_start) || l:grow_both_ends
    call MoveCursor('h')
  end

  call SyntaxMotion('h', '', 1)
  let l:start_pos = getpos(".")

  call setpos('.', l:v_end_pos)
  " TODO: Also move the cursor if this call to SelectSyntaxRegion() isn't
  " the first since entering a visual mode. This will need the VisualEnter
  " autocmd event, when it arrives. Until then, simulating VisualEnter fully
  " does not seem possible
  if (l:is_big_region && !l:is_at_start) || l:grow_both_ends
    call MoveCursor('l')
  end

  call SyntaxMotion('l', '', 1)
  let l:end_pos = getpos(".")

  call setpos('.', l:start_pos)
  normal v
  call setpos('.', l:end_pos)

  if l:is_at_start
    normal o
  end

endfunction

" [a and ]a are under development and not yet right
nnoremap <silent> ]a l:call SyntaxMotion('l', 'n', v:count)<CR>
vnoremap <silent> ]a l:call SyntaxMotion('l', 'v', v:count)<CR>
nnoremap <silent> [a h:call SyntaxMotion('h', 'n', v:count)<CR>
vnoremap <silent> [a h:call SyntaxMotion('h', 'v', v:count)<CR>

nnoremap <silent> +  :<c-u>call GrowVisualSelection('n','b')<CR>
nnoremap <silent> (  :<c-u>call GrowVisualSelection('n','h')<CR>
nnoremap <silent> )  :<c-u>call GrowVisualSelection('n','l')<CR>
vnoremap <silent> +  :<c-u>call GrowVisualSelection('v','b')<CR>
vnoremap <silent> (  :<c-u>call GrowVisualSelection('v','h')<CR>
vnoremap <silent> )  :<c-u>call GrowVisualSelection('v','l')<CR>
vnoremap <silent> ia :<c-u>call SelectSyntaxRegion('i')<CR>
vnoremap <silent> aa :<c-u>call SelectSyntaxRegion('a')<CR>
onoremap <silent> ia :normal via<CR>
onoremap <silent> aa :normal vaa<CR>

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
            syn off
            syn on
        endfunction

        augroup inactive_win
            au!
            au ColorScheme          * hi link InactiveWin ColorColumn | hi link NormalWin Normal
            au FileType,BufWinEnter * call s:configure_winhighlight()
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

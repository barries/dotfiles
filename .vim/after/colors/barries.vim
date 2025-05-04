" Reset to dark background, then reset everything to defaults:
set background=dark
highlight clear
if exists("syntax_on")
syntax reset
endif

let colors_name = "barries"

let g:cpp_class_scope_highlight = 1

hi Normal      ctermfg=White  guifg=#ffffff  ctermbg=Black  guibg=#000000
hi NormalNC    ctermbg=234    guibg=#1c1c1c
hi NormalFloat ctermbg=Grey   guibg=#A8A8A8  ctermfg=Black  guifg=#000000 " Haven't seen this work yet--I set it manually with winhl
hi EndOfBuffer ctermfg=021    guifg=#0000ff  ctermbg=Black  guibg=#000000 " tildes after last line in buffer
hi Visual      ctermbg=022    guibg=#005f00

hi SignColumn guibg=#202020

" Avoiding setting ctermfg because it breaks syntax highlighting
hi FocusedNormal        ctermbg=Black  guibg=#000000
hi FocusedEndOfBuffer   ctermfg=021    guifg=#0000ff  ctermbg=Black  guibg=#000000
hi UnfocusedNormal      ctermbg=234    guibg=#1c1c1c
hi UnfocusedEndOfBuffer ctermfg=021    guifg=#0000ff  ctermbg=234    guibg=#1c1c1c

" Syntax highlighting (other color-groups using default, see :help group-name):
hi Comment    cterm=NONE  gui=NONE  ctermfg=244     guifg=#808080
hi Constant   cterm=NONE  gui=NONE  ctermfg=117     guifg=#87dfff
hi Delimiter  cterm=bold  gui=bold  ctermfg=250     guifg=#bcbcbc
hi Function   cterm=NONE  gui=NONE  ctermfg=White   guifg=#ffffff
hi Identifier cterm=NONE  gui=NONE  ctermfg=White   guifg=#ffffff
hi PreProc    cterm=bold  gui=bold  ctermfg=248     guifg=#a8a8a8
hi Special    cterm=NONE  gui=NONE  ctermfg=Yellow  guifg=#ffff00
hi Statement  cterm=bold  gui=bold  ctermfg=250     guifg=#bcbcbc
hi Todo       cterm=bold  gui=bold  ctermfg=Yellow  guifg=#ffff00  ctermbg=none
hi Type       cterm=NONE  gui=NONE  ctermfg=195     guifg=#dfffff
hi Typedef    cterm=bold  gui=bold  ctermfg=195     guifg=#dfffff

hi cppSTLfunction ctermfg=159      guifg=#afffff
hi cCustomClass   ctermfg=255      guifg=#eeeeee
hi cCustomFunc    ctermfg=Blue     guifg=#4378ff
hi cppAccess      cterm=underline  gui=underline  ctermfg=195  guifg=#dfffff

hi TSConstructor  ctermfg=White  guifg=#ffffff " treesitter weirdly places a constructor attr on the RHS of -> method calls
hi TSFunction     ctermfg=White  guifg=#ffffff
hi TSMethod       ctermfg=White  guifg=#ffffff
hi TSConstBuiltin cterm=BOLD     gui=BOLD                                                                                   ctermfg=117  guifg=#87dfff

hi ivcgAlignment        cterm=underline  gui=underline  ctermfg=Green guifg=#00ff00
hi ivcgBlock            cterm=NONE       gui=NONE       ctermfg=Green guifg=#00ff00
hi ivcgBraces           cterm=NONE       gui=NONE       ctermfg=Green guifg=#00ff00
hi ivcgQuasiQuote       cterm=NONE       gui=NONE       ctermfg=Green guifg=#00ff00
hi ivcgKeywordDirective cterm=NONE       gui=NONE       ctermfg=Green guifg=#00ff00

hi PerlSpecialString ctermfg=LightCyan  guifg=#e0ffff ctermbg=234  guibg=#1c1c1c  cterm=underline  gui=underline

hi ColorColumn  cterm=NONE            gui=NONE            ctermbg=233         guibg=#121212
hi CursorColumn cterm=underline       gui=underline       ctermbg=none
hi CursorLine   cterm=underline       gui=underline       ctermbg=none
hi CursorLineNr ctermfg=248           guifg=#a8a8a8
hi MatchParen   cterm=bold            gui=bold            ctermfg=Black       guifg=#000000  ctermbg=Green   guibg=#008000
hi CurSearch    cterm=bold            gui=bold            ctermfg=Black       guifg=#000000  ctermbg=Yellow  guibg=#ffff00
hi Search       cterm=NONE            gui=NONE            ctermbg=214         guibg=#ffaf00
hi IncSearch    cterm=NONE            gui=NONE            ctermbg=214         guibg=#ffaf00
hi Substitute   cterm=NONE            gui=NONE            ctermfg=Yellow      guifg=#ffff00  " bg seems to be ignored
hi LineNr       ctermfg=240           guifg=#585858
hi NonText      cterm=bold            gui=bold            ctermfg=Green       ctermbg=Grey   guibg=#808080 " listchars extends, precedes, eol, etc.
hi Pmenu        ctermfg=Blue          guifg=#0000ff       ctermbg=017         guibg=#00005f  " Popup menu (autocompletion, etc)
hi PmenuSel     ctermfg=123           guifg=#87ffff       ctermbg=DarkBlue    guibg=#00008b  " Popup menu selected item
hi QuickFixLine cterm=bold,underline  gui=bold,underline
hi SpecialKey   cterm=NONE            gui=NONE            ctermfg=Green
hi Whitespace   cterm=bold            gui=bold            ctermfg=Yellow      guifg=#ffff00  " listchars tab, trail, space, etc,

hi DiffAdd      ctermbg=023 guibg=#005f5f
hi DiffDelete   ctermbg=236 guibg=#303030
hi DiffChange   ctermbg=017 guibg=#00005f
hi DiffText     ctermbg=019 guibg=#0000af

" statusline highlights (see %9*, etc, specifiers in statusline= settings
hi User4                cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=202  guibg=#ff5f00 " Modified
hi User5                cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=248  guibg=#a8a8a8 " Other flags
hi User9                cterm=NONE     gui=NONE       ctermfg=240    guifg=#585858  ctermbg=118  guibg=#87ff00 " Position in file
hi StatusLineSelected   ctermfg=Black  guifg=#000000  ctermbg=118    guibg=#87ff00
hi StatusLineUnselected ctermfg=Black  guifg=#000000  ctermbg=246    guibg=#949494

hi StatusLine     cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=118  guibg=#87ff00
hi WinSeparator   cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=118  guibg=#87ff00
hi WinSeparatorNC cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=118  guibg=#949494
hi StatusLineNC   cterm=NONE     gui=NONE       ctermfg=Black  guifg=#000000  ctermbg=246  guibg=#949494

hi Folded       cterm=NONE gui=NONE  ctermfg=246 guifg=#949494   ctermbg=236 guibg=#303030

" folke/which-key

hi WhichKeyNormal guifg=#ffffff guibg=#1c1c1c
hi WhichKeyBorder guifg=#87ff00 guibg=#1c1c1c
hi WhichKey       gui=bold guifg=#87ff00


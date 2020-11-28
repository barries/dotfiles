" Reset to dark background, then reset everything to defaults:
set background=dark
highlight clear
if exists("syntax_on")
    syntax reset
endif

let colors_name = "barries"

let g:cpp_class_scope_highlight = 1

hi Normal       ctermfg=White ctermbg=Black guifg=#ffffff guibg=Black
hi NormalNC                   ctermbg=234   guifg=#ffffff guibg=Black
hi NormalFloat  ctermbg=Grey  ctermfg=Black   " Haven't seen this work yet--I set it manually with winhl
hi EndOfBuffer  ctermfg=021   ctermbg=Black   " tildes after last line in buffer
hi Visual                     ctermbg=022

" Avoiding setting ctermfg because it breaks syntax highlighting
hi FocusedNormal                    ctermbg=Black
hi FocusedEndOfBuffer   ctermfg=021 ctermbg=Black
hi UnfocusedNormal                  ctermbg=234
hi UnfocusedEndOfBuffer ctermfg=021 ctermbg=234

" Syntax highlighting (other color-groups using default, see :help group-name):
hi Comment    cterm=NONE ctermfg=244                        gui=NONE guifg=#00aaaa
hi Constant   cterm=NONE ctermfg=117                        gui=NONE guifg=#00ffff
hi Delimiter  cterm=bold ctermfg=Yellow                     gui=NONE guifg=#ffff00
hi Function   cterm=NONE ctermfg=White                      gui=NONE guifg=#00ff00
hi Identifier cterm=NONE ctermfg=White                      gui=bold guifg=#ff00ff
hi PreProc    cterm=bold ctermfg=248                        gui=NONE guifg=#ffff00
hi Special    cterm=NONE ctermfg=Yellow                     gui=NONE guifg=#ff0000
hi Statement  cterm=bold ctermfg=250                        gui=bold guifg=#ffffff
hi Todo       cterm=bold ctermfg=Yellow ctermbg=none        gui=bold guifg=#ffffff
hi Type       cterm=NONE ctermfg=195                        gui=bold guifg=#00ff00
hi Typedef    cterm=bold ctermfg=195                        gui=NONE guifg=#ffff00

hi cppSTLfunction ctermfg=159
hi cCustomClass   ctermfg=255
hi cCustomFunc    ctermfg=Blue
hi cppAccess      cterm=underline ctermfg=195
hi TSConstructor ctermfg=White " treesitter weirdly places a constructor attr on the RHS of -> method calls
hi TSFunction ctermfg=White
hi TSMethod   ctermfg=White

hi ivcgAlignment        cterm=underline      ctermfg=Green        gui=NONE guifg=#ffff00
hi ivcgBlock            cterm=NONE           ctermfg=Green        gui=NONE guifg=#ffff00
hi ivcgBraces           cterm=NONE           ctermfg=Green        gui=NONE guifg=#ffff00
hi ivcgQuasiQuote       cterm=NONE           ctermfg=Green        gui=NONE guifg=#ffff00
hi ivcgKeywordDirective cterm=NONE           ctermfg=Green        gui=NONE guifg=#ffff00

hi PerlSpecialString            ctermfg=LightCyan ctermbg=234 cterm=underline

hi ColorColumn  cterm=NONE                      ctermbg=233
hi CursorColumn cterm=underline                 ctermbg=none
hi CursorLine   cterm=underline                 ctermbg=none
hi CursorLineNr                 ctermfg=248
hi MatchParen   cterm=bold      ctermfg=blue    ctermbg=bg
hi Search       cterm=NONE                      ctermbg=Yellow
hi IncSearch    cterm=NONE                      ctermbg=214
hi Substitute   cterm=NONE      ctermfg=Yellow  " bg seems to be ignored
hi LineNr                       ctermfg=240
hi NonText      cterm=bold      ctermfg=Green   ctermbg=008         " listchars extends, precedes, eol, etc.
hi Pmenu                        ctermfg=Blue    ctermbg=017         " Popup menu (autocompletion, etc)
hi PmenuSel                     ctermfg=123     ctermbg=DarkBlue    " Popup menu selected item
hi QuickFixLine cterm=bold,underline
hi SpecialKey   cterm=NONE      ctermfg=Green
hi Whitespace   cterm=bold      ctermfg=Yellow                      " listchars tab, trail, space, etc,

hi DiffAdd                                      ctermbg=023
hi DiffDelete                                   ctermbg=236
hi DiffChange                                   ctermbg=017
hi DiffText                                     ctermbg=019

" statusline highlights (see %9*, etc, specifiers in statusline= settings
hi User4        cterm=NONE  ctermfg=Black ctermbg=202 " Modified
hi User5        cterm=NONE  ctermfg=Black ctermbg=248 " Other flags
hi User9        cterm=NONE  ctermfg=240   ctermbg=118 " Position in file
hi StatusLineSelected       ctermfg=Black ctermbg=118
hi StatusLineUnselected     ctermfg=Black ctermbg=246

hi StatusLine   cterm=NONE  ctermfg=Black ctermbg=118
hi VertSplit                ctermfg=246   ctermbg=0
hi StatusLineNC cterm=NONE  ctermfg=Black ctermbg=246

hi Folded       cterm=NONE  ctermfg=246   ctermbg=236

" vim-mark colors
"hi MarkWord1 ctermbg=cyan    ctermfg=Black
"hi MarkWord2 ctermbg=034     ctermfg=Black
"hi MarkWord3 ctermbg=grey    ctermfg=Black
"hi MarkWord4 ctermbg=red     ctermfg=Black
"hi MarkWord5 ctermbg=magenta ctermfg=Black
"hi MarkWord6 ctermbg=blue    ctermfg=Black

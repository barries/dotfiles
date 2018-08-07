" Vim syntax file
" Language: IVCG
" Maintainer: Barrie Slaymaker

if exists("b:current_syntax")
  finish
endif

runtime! syntax/cpp.vim
syntax include @C   syntax/c.vim
syntax include @CPP syntax/cpp.vim

let b:current_syntax = "cpp_ivcg"

syntax match  ivcgAlignment        "`|" containedin=ALL
syntax region ivcgBlock            matchgroup=ivcgBraces start="`{" end="`}" contains=@CPP,@C
syntax match  ivcgKeywordDirective "`\(do\|else\|elsif\|for\|if\|while\|SORT_LINES\|UNIQ\|TRIM_IF_EMPTY\|TRIM_IF_ONE_LINE\)" containedin=All
syntax match  ivcgQuasiQuote       "`[a-zA-Z0-9_]\+`" containedin=ALL,cBlock

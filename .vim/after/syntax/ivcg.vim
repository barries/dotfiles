" Vim syntax file
" Language: IVCG
" Maintainer: Barrie Slaymaker

if exists("b:current_syntax")
  finish
endif

let b:current_syntax = "ivcg"

syntax match  ivcgAlignment        "`|" containedin=ALL
syntax match  ivcgQuasiQuote       "`[^{}][^`]\{-}`" containedin=ALL
syntax match  ivcgText             "[^`]*" containedin=ivcgBlock contains=ivcgBlock
syntax region ivcgBlock            matchgroup=ivcgBraces start="`\(do\|else\|elsif\|for\|if\|while\)[^`]*`{" end="`}" contains=ivcgText

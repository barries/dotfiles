" Vim syntax file
" Language: IVCG
" Maintainer: Barrie Slaymaker

if exists("b:current_syntax")
  finish
endif

runtime! syntax/lua.vim
syntax include @LUA syntax/lua.vim

let b:current_syntax = "lua_ivcg"

syntax match  ivcgAlignment        "`|" containedin=ALL
syntax match  ivcgQuasiQuote       "`[^{}][^`]\{-}`" containedin=ALL
syntax match  ivcgText             "[^`]*" containedin=ivcgBlock contains=ivcgBlock,@LUA
syntax region ivcgBlock            matchgroup=ivcgBraces start="`\(do\|else\|elsif\|for\|if\|while\)[^`]*`{" end="`}" contains=ivcgText,@LUA

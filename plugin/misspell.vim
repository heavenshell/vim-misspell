" File: misspell.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-misspell/
" Description: misspell for Vim
" License: BSD, see LICENSE for more details.
" Copyright: 2017 Shinya Ohyanagi. All rights reserved.
let s:save_cpo = &cpo
set cpo&vim

if get(b:, 'loaded_misspell')
  finish
endif

" version check
if !has('channel') || !has('job')
  echoerr '+channel and +job are required for misspell.vim'
  finish
endif

command! Misspell :call misspell#run()

noremap <silent> <buffer> <Plug>(Misspell)  :Misspell<CR>

let b:loaded_misspell = 1

let &cpo = s:save_cpo
unlet s:save_cpo

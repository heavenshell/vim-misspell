" File: misspell.vim
" Author: Shinya Ohyanagi <sohyanagi@gmail.com>
" WebPage:  http://github.com/heavenshell/vim-misspell/
" Description: misspell for Vim
" License: BSD, see LICENSE for more details.
" Copyright: 2017 Shinya Ohyanagi. All rights reserved.
let s:save_cpo = &cpo
set cpo&vim

let g:misspell_bin = get(g:, 'misspell_bin', '')
let g:misspell_enable_quickfix = get(g:, 'misspell_enable_quickfix', 0)
let g:misspell_callbacks = get(g:, 'misspell_callbacks', {})
let g:misspell_ignores = get(g:, 'misspell_ignores', '')
let g:misspell_locale = get(g:, 'misspell_locale', '')

let s:bin = ''
let s:results = []

function! s:parse(msg, file)
  " Output format is following.
  "   stdin:1:0: "zeebra" is a misspelling of "zebra"
  "   col is start with `0`.
  let lines = split(a:msg, ':')
  call add(s:results, {
        \ 'filename': a:file,
        \ 'lnum': lines[1],
        \ 'col': lines[2] + 1,
        \ 'vcol': 0,
        \ 'text': printf('[Misspell]%s', lines[3]),
        \ })
endfunction

function! s:callback(ch, msg, file)
  call s:parse(a:msg, a:file)
endfunction

function! s:exit_callback(ch, msg, mode)
  if len(s:results) == 0
    return
  endif
  " echomsg printf('[Misspell] %s errors found', len(s:results))

  if len(s:results) == 0 && len(getqflist()) == 0
    " No Errors. Clear quickfix then close window if exists.
    call setqflist([], 'r')
    cclose
  else
    call setqflist(s:results, a:mode)
    if g:misspell_enable_quickfix == 1
      cwindow
    endif
  endif

  if has_key(g:misspell_callbacks, 'after_run')
    call g:misspell_callbacks['after_run'](a:ch, a:msg)
  endif
endfunction

function! s:error_callback(ch, msg)
  echomsg printf('err: %s', a:msg)
endfunction

function! misspell#bin() abort
  if s:bin != ''
    return s:bin
  endif
  if executable('misspell') == 0
    let s:bin = g:misspell_bin
  else
    let s:bin = exepath('misspell')
  endif
  if s:bin == ''
    return
  endif

  return s:bin
endfunction

function! misspell#run(...)
  let bin = misspell#bin()
  if exists('s:job') && job_status(s:job) != 'stop'
    call job_stop(s:job)
  endif
  let s:results = []

  let mode = a:0 > 0 ? a:1 : 'r'
  let cmd = bin
  if g:misspell_locale != ''
    let cmd = cmd . ' -locale ' . g:misspell_locale
  endif
  if g:misspell_ignores != ''
    let cmd = cmd . ' -i ' . g:misspell_ignores
  endif
  let file = expand('%:p')
  " Send buffe directly raises SEGV.
  " let s:job = job_start(cmd, {
  "       \ 'callback': {c, m -> s:callback(c, m, file)},
  "       \ 'exit_cb': {c, m -> s:exit_callback(c, m, mode)},
  "       \ 'err_cb': {c, m -> s:error_callback(c, m)},
  "       \ 'in_io': 'buffer',
  "       \ 'in_name': file,
  "       \ })
  let bufnum = bufnr('%')
  let input = join(getbufline(bufnum, 1, '$'), "\n") . "\n"
  let s:job = job_start(cmd, {
        \ 'callback': {c, m -> s:callback(c, m, file)},
        \ 'exit_cb': {c, m -> s:exit_callback(c, m, mode)},
        \ 'err_cb': {c, m -> s:error_callback(c, m)},
        \ 'in_mode': 'nl',
        \ })

  let channel = job_getchannel(s:job)
  if ch_status(channel) ==# 'open'
    call ch_sendraw(channel, input)
    call ch_close_in(channel)
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

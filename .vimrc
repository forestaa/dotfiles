" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
" Initialize plugin system
call plug#end()

" basic settings
colorscheme molokai
" allow plugin to detect filetype
filetype plugin indent on 
" syntax highlight
syntax on
" backspace settings
set backspace=indent,eol,start
" show line number
set number
" tab length
set tabstop=2
set expandtab
set shiftwidth=2

" no swap file
set noswapfile

" clipboard settings between vim and os
" set clipboard=unnamed
" set clipboard+=autoselect
set clipboard+=unnamedplus

" mouse scroll, but it doesn't work in tmux
if has('mouse')
	set mouse=a
endif

" neovim
if has('nvim')
  let g:clipboard = {
  \   'name': 'win32yank',
  \   'copy': {
  \     '+': '/mnt/c/Users/tdaic/AppData/Local/win32yank/win32yank.exe -i',
  \     '*': '/mnt/c/Users/tdaic/AppData/Local/win32yank/win32yank.exe -i',
  \   },
  \   'paste': {
  \     '+': '/mnt/c/Users/tdaic/AppData/Local/win32yank/win32yank.exe -o',
  \     '*': '/mnt/c/Users/tdaic/AppData/Local/win32yank/win32yank.exe -o',
  \   },
  \   'cache_enabled': 1,
  \ }
endif


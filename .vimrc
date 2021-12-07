" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.vim/plugged')

Plug 'tomasr/molokai'
Plug 'tpope/vim-surround'
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

" swap up and down key
if exists('g:vscode')
  nmap j gj
  nmap k gk
else
  nnoremap j gj
  nnoremap k gk
  nnoremap gj j
  nnoremap gk k
endif

" mouse scroll, but it doesn't work in tmux
if has('mouse')
	set mouse=a
endif

" neovim
if has('nvim')
endif


if &compatible
  set nocompatible               " Be iMproved
endif

augroup MyAutoCmd
	autocmd!
  autocmd VimEnter * call dein#call_hook('post_source')

  autocmd ColorScheme * highlight Normal      ctermbg=none
  autocmd ColorScheme * highlight NonText     ctermbg=none
  autocmd ColorScheme * highlight LineNr      ctermbg=none
  autocmd ColorScheme * highlight Folded      ctermbg=none
  autocmd ColorScheme * highlight EndOfBuffer ctermbg=none
augroup END

augroup MyQuickFix
  autocmd!

  autocmd QuickFixCmdPost *grep* cwindow
  " auto-close quickfix window
  autocmd WinEnter * if (winnr('$') == 1) && (getbufvar(winbufnr(0), '&buftype')) == 'quickfix' | quit | endif
augroup END

" install plugins into this directory
let s:dein_dir = expand('~/.cache/dein')
" dein.vim
let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" download dein.vim if does not exist
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

" dein settings
if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  " TOML
  let g:rc_dir    = expand('~/.vim/rc')
  let s:toml      = g:rc_dir . '/dein.toml'
  let s:lazy_toml = g:rc_dir . '/dein_lazy.toml'

  " load and cache TOML
  call dein#load_toml(s:toml,      {'lazy': 0})
  call dein#load_toml(s:lazy_toml, {'lazy': 1})

  " finish settings
  call dein#end()
  call dein#save_state()
endif

" install plugins if does not exist
if dein#check_install()
  call dein#install()
endif

" basic settings
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

" swap up and down key
nnoremap j gj
nnoremap k gk
nnoremap gj j
nnoremap gk k

" neovim
if has('nvim')
  let g:python_host_prog = '/home/foresta/.anyenv/envs/pyenv/versions/2.7.16/envs/neovim2/bin/python'
  let g:python3_host_prog = '/home/foresta/.anyenv/envs/pyenv/versions/3.7.3/envs/neovim3/bin/python'

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


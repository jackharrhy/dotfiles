" Vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'gmarik/Vundle.vim'

" Distraction-free modes
Plugin 'junegunn/goyo.vim'
Plugin 'junegunn/limelight.vim'

" Editor Config
Plugin 'editorconfig/editorconfig-vim'

" Color Schemes
Plugin 'flazz/vim-colorschemes'

" Lang support
Plugin 'LnL7/vim-nix'
Plugin 'dag/vim-fish'
Plugin 'rhysd/vim-crystal'
Plugin 'plasticboy/vim-markdown'
Plugin 'elixir-editors/vim-elixir'

call vundle#end()
filetype plugin indent on

" Smol Indenting
set softtabstop=2
set shiftwidth=2
set expandtab

" Line Numbering
" set relativenumber

" Syntax
syntax on
colorscheme devbox-dark-256

" Use ctrl-[hjkl] to select the active split
nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>

" Vim-Airline Theme
let g:airline_theme='bubblegum'

" Limelight
autocmd! User GoyoEnter Limelight
autocmd! User GoyoLeave Limelight!

" Disable folding
let g:vim_markdown_folding_disabled = 1

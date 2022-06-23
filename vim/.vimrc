" vim-plug
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

" Distraction-free modes
Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'

" Editor Config
Plug 'editorconfig/editorconfig-vim'

" Color Schemes
Plug 'flazz/vim-colorschemes'

" Lang support
Plug 'dag/vim-fish'
Plug 'rhysd/vim-crystal'
Plug 'plasticboy/vim-markdown'
Plug 'elixir-editors/vim-elixir'

call plug#end()

filetype plugin indent on

" Smol Indenting
set softtabstop=2
set shiftwidth=2
set expandtab

" Line Numbering
set relativenumber

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

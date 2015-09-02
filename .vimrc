" Vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
	Plugin 'VundleVim/Vundle.vim'

	Plugin 'flazz/vim-colorschemes'

	Plugin 'Bling/vim-airline'

	Plugin 'ervandew/supertab'
	Plugin 'honza/vim-snippets'

	Plugin 'tpope/vim-markdown'

	Plugin 'othree/html5.vim'
	Plugin 'mattn/emmet-vim'
	Plugin 'hail2u/vim-css3-syntax'
	Plugin 'groenewege/vim-less'

	Plugin 'digitaltoad/vim-jade'
	Plugin 'pangloss/vim-javascript'
call vundle#end()
filetype plugin indent on

" Syntax
:syntax on
:colorscheme xoria256

" Indenting
set shiftwidth=2
set tabstop=2

" Numbering
:set relativenumber

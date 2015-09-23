" Vundle
set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
	Plugin 'gmarik/Vundle.vim'

	Plugin 'flazz/vim-colorschemes'

	Plugin 'tpope/vim-markdown'

	Plugin 'ervandew/supertab'
	Plugin 'honza/vim-snippets'

	Plugin 'othree/html5.vim'
	Plugin 'mattn/emmet-vim'
	Plugin 'hail2u/vim-css3-syntax'
	Plugin 'groenewege/vim-less'
	Plugin 'ap/vim-css-color'

	Plugin 'elzr/vim-json'
	Plugin 'digitaltoad/vim-jade'
	Plugin 'pangloss/vim-javascript'
	Plugin 'walm/jshint.vim'

	Plugin 'quabug/vim-gdscript'
call vundle#end()
filetype plugin indent on

" Indenting
setlocal shiftwidth=2
setlocal tabstop=2

" Line Numbering
set relativenumber
set number

" Syntax
syntax on
colorscheme mrkn256

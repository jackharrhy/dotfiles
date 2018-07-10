#!/bin/bash

COLOR='\033[0;36m'
NC='\033[0m'

# ARCH LINUX
function arch() {
	printf "copying doit.sh -> ~/doit\n"
	cp ./scripts/doit.sh ~/doit
	printf "creating combined .zshrc for arch -> ~/.zshrc\n"
	cat ./zsh/zshrc-arch.sh ./zsh/zshrc-universal.sh ./nvm/nvm.sh > ~/.zshrc
}
function i3() {
	printf "copying i3config-base.sh -> ~/.config/i3/config\n"
	cp ./wm/i3config-base.sh ~/.config/i3/config
}
function i3multimon() {
	printf "creating combined config for i3 -> ~/.config/i3/config\n"
	cat ./wm/i3config-base.sh ./wm/i3config-multimon.sh > ~/.config/i3/config
}

# POP-OS
function popos() {
	printf "creating combined .zshrc for popos -> ~/.zshrc\n"
	cat ./zsh/zshrc-popos.sh ./zsh/zshrc-universal.sh ./nvm/nvm.sh > ~/.zshrc
}

# UBUNTU
function ubuntu() {
	printf "creating combined .zshrc for ubuntu -> ~/.zshrc\n"
	cat ./zsh/zshrc-ubuntu.sh ./zsh/zshrc-base.sh ./nvm/nvm.sh > ~/.zshrc
}

# MACOS
function macos() {
	printf "creating combined .zshrc for ubuntu -> ~/.zshrc\n"
	cat ./zsh/zshrc-macos.sh ./zsh/zshrc-universal.sh ./nvm/nvm.sh > ~/.zshrc
}

# UNIVERSAL
function fonts() {
	printf "setting terminal font\n"
	sourceCodeProFiles=$(fc-list | grep -i "Source Code Pro")
	if [ -z sourceCodeProFiles ]; then
		printf "The font \"Source Code Pro\" is not currently installed\n"
		cat ./wm/xdefaults-base ./wm/xdefaults-defaultfont > ~/.Xdefaults
	else
		cat ./wm/xdefaults-base ./wm/xdefaults-sourcecodepro > ~/.Xdefaults
	fi
}
function tmux() {
	printf "copying tmux -> ~/.tmux.conf\n"
	cp ./term/tmux.conf ~/.tmux.conf
}
function vim() {
	printf "copying vimrc -> ~/.vimrc\n"
	cp ./term/vimrc ~/.vimrc
}

# INSTALLS
function vundle() {
	printf "installing vundle"
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
}
function ohmyzsh() {
	printf "installing ohmyzsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}
function nvminstall() {
	printf "installing ohmyzsh"
	curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
}

function inform() {
	printf "${COLOR}\n"
	printf " choices:\n"
	printf "    configs:\n"
	printf "  1 - arch\n"
	printf "    + fonts, i3, tmux, vim\n"
	printf "  2 - arch-multimon\n"
	printf "    + fonts, i3multimon, tmux, vim\n"
	printf "\n"
	printf "  3 - ubuntu-nogui\n"
	printf "    + tmux, vim\n"
	printf "\n"
	printf "  4 - pop-os\n"
	printf "    + fonts, tmux, vim\n"
	printf "\n"
	printf "  5 - macos\n"
	printf "    + fonts, tmux, vim\n"
	printf "\n"
	printf "    installs:\n"
	printf "  6 - vundle\n"
	printf "  7 - oh-my-zsh\n"
	printf "  8 - nvm\n"
	printf "${NC}\n"
}

if [ $1 ]; then
	case $1 in
		1) # arch
			arch
			fonts
			i3
			tmux
			vim;;
		2) # arch-multimon
			arch
			fonts
			i3multimon
			tmux
			vim;;
		3) # ubuntu-nogui
			ubuntu
			tmux
			vim;;
		4) # pop-os
			popos
			fonts
			tmux
			vim;;
		5) # macos
			macos
			fonts
			tmux
			vim;;
		6) # vundle
			vundle
			;;
		7) # oh-my-zsh
			ohmyzsh
			;;
		8) # nvminstall
			nvminstall
			;;
		*)
			inform
	esac

else
	inform
fi

# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

NAME=$(uname -r)

if [[ $NAME == *"ARCH"* ]]; then
	# Pacman
	alias p='sudo pacman'
	alias i='sudo pacman -S'
	alias u='sudo pacman -Su'
	alias ud='sudo pacman -Syu'
	alias r='sudo pacman -Rdds'

	# Yaourt
	alias yi='yaourt -S'

	# Window Manager
	alias autostart='vim ~/.config/herbstluftwm/autostart'
	alias rs='redshift -l 47.565520:-52.765419'

	# Video Player
	alias v='mpv'
else
	# set variable identifying the chroot you work in (used in the prompt below)
	if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
		debian_chroot=$(cat /etc/debian_chroot)
	fi

	# Apt-get
	alias i='sudo apt-get install'
	alias r='sudo apt-get remove'
	alias u='sudo apt-get update'
	alias ug='sudo apt-get upgrade'
	alias ugd='sudo apt-get dist-upgrade'
fi

# UNIVERSAL

# enable programmable completion features
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command
shopt -s checkwinsize


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto -h'
	alias dir='dir --color=auto'
	alias vdir='vdir --color=auto'

	alias grep='grep --color=auto'
	alias fgrep='fgrep --color=auto'
	alias egrep='egrep --color=auto'
fi


# Prompt
export PS1="\[\033[38;5;229m\]\T\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]-\[$(tput sgr0)\] \[$(tput sgr0)\]\[\033[38;5;180m\]\d\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;75m\][\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\]\w\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;75m\]]\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]\[\033[38;5;248m\]\$?\[$(tput sgr0)\]\[\033[38;5;15m\]\n\[$(tput sgr0)\]\[\033[38;5;48m\]\u\[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;216m\]@\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;152m\]\h\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput bold)\]\[$(tput sgr0)\]\[\033[38;5;155m\]>\[$(tput sgr0)\]\[$(tput sgr0)\]\[\033[38;5;15m\] \[$(tput sgr0)\]"

# LS
alias l='ls -l'
alias la='ls -l -a'

# Config Files
alias vimrc='vim ~/.vimrc'
alias bashrc='vim ~/.bashrc'
alias xdefaults='vim ~/.Xdefaults'

# Suspend
alias night='systemctl suspend'

# Rust Fix
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib

# Cmatrix Binds
alias matrix='cmatrix -C red -b -l -u 10'

# Trash
alias rm='trash'

# tmux
alias tmux='TERM=xterm-256color tmux -2'

# editor
EDITOR=vim

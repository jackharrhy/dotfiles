# UNIVERSAL

EDITOR=vim

export ZSH=~/.oh-my-zsh

plugins=(
  git,

  node,
  npm,
  nvm,

  osx,
  colorize,
  cp,
  tmux
  vi-mode
  vundle
)

source $ZSH/oh-my-zsh.sh

autoload -U promptinit; promptinit
prompt pure

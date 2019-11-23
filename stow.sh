#!/usr/bin/env sh

s() {
  read -p "stow $1? : " -n 1 -r
  case "$REPLY" in
    y|Y ) stow $1;;
    n|N ) printf "\nskippin $1...\n";;
    *)
      printf "\ninvalid choice, exiting...\n"
      exit 0;;
  esac
}

s git
s herbs
s term
s tmux
s vim

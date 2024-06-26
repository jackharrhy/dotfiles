#!/usr/bin/env bash

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

s fish
s git
s herbs
s term
s tmux
s vim
s xinit

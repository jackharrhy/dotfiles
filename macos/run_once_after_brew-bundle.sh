#!/bin/sh
command -v brew >/dev/null 2>&1 || exit 0
brew bundle --file "$HOME/Brewfile"

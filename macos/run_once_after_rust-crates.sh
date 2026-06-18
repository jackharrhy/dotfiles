#!/bin/sh
command -v mise >/dev/null 2>&1 || exit 0
mise exec -- cargo --version >/dev/null 2>&1 || exit 0
mise exec -- cargo install ripgrep fd-find bat eza zoxide git-delta dust procs hyperfine sd

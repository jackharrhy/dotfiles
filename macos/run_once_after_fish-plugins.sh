#!/bin/sh
command -v fish >/dev/null 2>&1 || exit 0
fish -c 'if not functions -q fisher; set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config; curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish; end; fisher update'

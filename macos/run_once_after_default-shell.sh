#!/bin/sh
FISH=$(command -v fish) || exit 0
grep -qx "$FISH" /etc/shells || echo "$FISH" | sudo tee -a /etc/shells >/dev/null
[ "$SHELL" = "$FISH" ] || chsh -s "$FISH"

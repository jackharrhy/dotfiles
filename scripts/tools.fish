#!/usr/bin/env fish
switch "$argv[1]"
    case install
        set operation install
    case update
        set operation upgrade
    case '*'
        echo 'Usage: tools.fish install|update' >&2
        exit 2
end

set config_home "$HOME/.config"
set -q XDG_CONFIG_HOME; and set config_home "$XDG_CONFIG_HOME"
if not test -f "$config_home/mise/config.toml"
    echo 'Apply the reviewed global mise config first.' >&2
    exit 1
end
if test -f "$HOME/.tool-versions"
    echo 'Review and migrate ~/.tool-versions before using the fleet tool commands.' >&2
    exit 1
end

# Do not inherit a project's runtime selectors from the checkout.
cd "$HOME"; or exit 1
exec mise $operation --yes

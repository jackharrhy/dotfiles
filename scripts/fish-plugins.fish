#!/usr/bin/env fish

set -l mode $argv[1]
if not contains -- "$mode" install update
    echo 'Usage: fish-plugins.fish install|update' >&2
    exit 2
end
set -l manifest $__fish_config_dir/fish_plugins
if not test -f "$manifest"
    echo 'Apply the reviewed Fish plugin manifest first.' >&2
    exit 1
end
set -l desired (string match --regex -- '^[^\s#]+$' < "$manifest")
if not contains -- jorgebucaran/fisher $desired
    echo 'The plugin manifest must include jorgebucaran/fisher.' >&2
    exit 1
end
if set -q fisher_path; and test "$fisher_path" != "$__fish_config_dir"
    echo 'Review the custom fisher_path before installing plugins.' >&2
    exit 1
end

set -l installed
if type -q fisher
    set installed (fisher list)
end
if not contains -- jorgebucaran/fisher $installed
    set -l bootstrap (mktemp); or exit 1
    if not curl -qfsSL https://raw.githubusercontent.com/jorgebucaran/fisher/4.4.8/functions/fisher.fish -o "$bootstrap"
        command rm "$bootstrap"
        exit 1
    end
    # Adopt an orphaned official Fisher file, but never overwrite a custom one.
    set -l existing $__fish_config_dir/functions/fisher.fish
    if test -e "$existing"; or test -L "$existing"
        if test -L "$existing"; or not command cmp -s "$existing" "$bootstrap"
            echo 'Existing unregistered fisher.fish differs from upstream; review it first.' >&2
            command rm "$bootstrap"
            exit 1
        end
        command rm "$existing"
    end
    source "$bootstrap"
    set -l result $status
    command rm "$bootstrap"
    test "$result" -eq 0; or exit "$result"
end

set -l missing
for plugin in $desired
    contains -- "$plugin" $installed; or set -a missing "$plugin"
end
if test (count $missing) -gt 0
    fisher install $missing </dev/null; or exit 1
end
if test "$mode" = update
    fisher update $desired </dev/null; or exit 1
end
for plugin in $desired
    if not contains -- "$plugin" (fisher list)
        echo "Plugin installation did not complete: $plugin" >&2
        exit 1
    end
end

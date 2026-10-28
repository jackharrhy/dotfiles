#!/usr/bin/env fish
set mode "$argv[1]"
if not contains -- "$mode" install update
    echo 'Usage: packages-apt.fish install|update' >&2
    exit 2
end
if test (uname -s) != Linux
    echo 'This installer requires Linux/apt.' >&2
    exit 1
end
set host (hostname -s)
if not contains -- "$host" newport mug
    echo 'Unrecognized Linux host; review its package list first.' >&2
    exit 1
end
set root (path resolve (status dirname)/..)

if test "$mode" = update
    sudo apt-get update; or exit $status
end
set packages
for file in "$root/packages/linux.txt" "$root/packages/$host.txt"
    test -f "$file"; or continue
    while read -l package
        set installed (dpkg-query -W -f='${Status}' "$package" 2>/dev/null)
        if test "$mode" = install; and test "$installed" != 'install ok installed'
            set -a packages "$package"
        else if test "$mode" = update; and test "$installed" = 'install ok installed'
            set -a packages "$package"
        end
    end < "$file"
end
if set -q packages[1]
    if test "$mode" = update
        set -p packages --only-upgrade
    end
    exec sudo env DEBIAN_FRONTEND=noninteractive NEEDRESTART_MODE=l apt-get install --yes --no-remove --no-install-recommends $packages
end

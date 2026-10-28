#!/usr/bin/env fish
set mode "$argv[1]"
if not contains -- "$mode" install update
    echo 'Usage: rust.fish install|update' >&2
    exit 2
end
if test (hostname -s) = mug
    echo 'Rust is not part of the Mug baseline.' >&2
    exit 1
end
if test -x "$HOME/.cargo/bin/rustup"
    set rustup "$HOME/.cargo/bin/rustup"
else if command -sq rustup
    set rustup (command -s rustup)
else
    echo 'Install the official rustup binary before managing Rust.' >&2
    exit 1
end
if test "$mode" = update
    $rustup update stable; or exit $status
else
    set toolchains ($rustup toolchain list)
    or exit $status
    if not string match -qr '^stable-' -- $toolchains
        $rustup toolchain install stable --profile default; or exit $status
    end
end
exec $rustup component add --toolchain stable rustfmt clippy

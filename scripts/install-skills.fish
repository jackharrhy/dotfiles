#!/usr/bin/env fish
if not command -sq skills
    echo 'Run mise run skills:install to supply the skills CLI.' >&2
    exit 1
end
if not test -f "$HOME/skills-lock.json"
    echo 'Apply the reviewed ~/skills-lock.json before installing skills.' >&2
    exit 1
end
if test -L "$HOME/.agents"; or test -L "$HOME/.agents/skills"
    echo 'Review the symlinked canonical skills root before installing.' >&2
    exit 1
end

umask 077
# The CLI restores relative to cwd; HOME makes its canonical path user-wide.
cd "$HOME"; or exit 1
exec env DISABLE_TELEMETRY=1 DO_NOT_TRACK=1 skills experimental_install

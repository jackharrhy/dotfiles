if test (uname -s) = Darwin
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    end
end

for directory in ~/.opencode/bin ~/.cargo/bin ~/.local/bin
    if test -d "$directory"
        fish_add_path --path "$directory"
    end
end
set --erase directory
if test -d ~/.local/lib/pkgconfig
    if not contains -- "$HOME/.local/lib/pkgconfig" $PKG_CONFIG_PATH
        set -gx PKG_CONFIG_PATH ~/.local/lib/pkgconfig $PKG_CONFIG_PATH
    end
end

if not set -q EDITOR
    set -gx EDITOR vim
end

if command -sq mise
    if status is-interactive
        command mise activate fish | source
    else
        command mise activate fish --shims | source
    end
end

if status is-interactive
    # Skip mise shims: merely running an optional init command can install tools.
    function __dotfiles_has_command --argument-names name
        set -l executable (command -s "$name"); or return 1
        set -l resolved (path resolve -- "$executable"); or return 1
        set -l mise_executable (command -s mise)
        if test -n "$mise_executable"
            test "$resolved" = (path resolve -- "$mise_executable"); and return 1
        end
        test (path basename -- "$resolved") != mise
    end

    if __dotfiles_has_command direnv
        direnv hook fish | source
    end
    if __dotfiles_has_command zoxide
        zoxide init fish | source
    end
    if __dotfiles_has_command starship
        starship init fish | source
    end
    __dotfiles_has_command nvim; and alias vim nvim
    __dotfiles_has_command bat; and alias cat bat
    if __dotfiles_has_command eza
        alias ls eza
        alias ll "eza -la"
        alias lt "eza --tree"
    end
    functions --erase __dotfiles_has_command

    function fish_greeting
        date
    end
end

if test -f "$__fish_config_dir/local.fish"
    source "$__fish_config_dir/local.fish"
end

set -gx EDITOR vim

if test -x /opt/homebrew/bin/brew
    eval (/opt/homebrew/bin/brew shellenv)
else if test -x /usr/local/bin/brew
    eval (/usr/local/bin/brew shellenv)
end

fish_add_path ~/.opencode/bin

if type -q mise
    mise activate fish | source
end

if type -q direnv
    direnv hook fish | source
end

if type -q zoxide
    zoxide init fish | source
end

if type -q starship
    starship init fish | source
end

if type -q fzf
    fzf --fish | source
end

alias vim nvim
alias cat bat
alias ls eza
alias ll "eza -la"
alias lt "eza --tree"

test -f ~/.orbstack/shell/init2.fish; and source ~/.orbstack/shell/init2.fish

function fish_greeting
  date
end

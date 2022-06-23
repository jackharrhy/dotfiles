set EDITOR vim
set -gx PATH "$HOME/.cargo/bin" $PATH

thefuck --alias | source

function gradient
  source ~/.pyenv/versions/gradient/bin/activate.fish
end

#set -Ux PYENV_ROOT $HOME/.pyenv
#set -Ux fish_user_paths $PYENV_ROOT/bin $fish_user_paths

source ~/.asdf/asdf.fish

if not functions -q fisher
  set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
  curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
  fish -c fisher
end

function op-getpass
  op get item $argv[1] | jq '.details.fields[] | select(.designation=="password").value'
end

function op-getitem
  op get item $argv[1] | jq
end

function op-getsections
  op get item $argv[1] | jq '.details.sections'
end

function op-signin
  eval (op signin)
end

function fish_greeting
  date
end

function ultra
  xrandr --newmode "2560x1080_60.00"  230.00  2560 2720 2992 3424  1080 1083 1093 1120 -hsync +vsync
  xrandr --addmode HDMI-1 2560x1080_60.00
  xrandr --output eDP-1 --primary --mode 1920x1080 --pos 260x1080 --rotate normal --output DP-1 --off --output HDMI-1 --mode 2560x1080_60.00 --pos 0x0 --rotate normal --output DP-2 --off --output HDMI-2 --off
  herbstclient detect_monitors
  herbstclient reload
  sudo netctl stop-all
  sudo netctl start blackhole
end

function mun
  sudo netctl stop-all
  sudo netctl start mun-guest
end

function munmon
  echo "1920x1080 59.96 Hz (CVT 2.07M9) hsync: 67.16 kHz; pclk: 173.00 MHz"
  xrandr --newmode "1920x1080_60.00"  173.00  1920 2048 2248 2576  1080 1083 1088 1120 -hsync +vsync
end

function mybar
  while true
    acpi
    date
    sleep 5
end
end

function clc
  set BRANCH (git rev-parse --abbrev-ref HEAD)
  set LAST_COMMIT_SHA (git rev-parse $BRANCH | tail -n 1)
  echo "$LAST_COMMIT_SHA" | tr -d '\n' | pbcopy
  echo "Copied $LAST_COMMIT_SHA from branch $BRANCH to clipboard via pbcopy."
end

function prc
  set BRANCH (git rev-parse --abbrev-ref HEAD)
  set COMMENT $argv[1]

  git commit -m $COMMENT
  git push origin
  clc
end

set -gx WASMTIME_HOME "$HOME/.wasmtime"

string match -r ".wasmtime" "$PATH" > /dev/null; or set -gx PATH "$WASMTIME_HOME/bin" $PATH

set -U DENO_INSTALL /home/jack/.deno

fish_add_path \
  /usr/local/go/bin \
  /home/jack/software/zig \
  /home/jack/.pulumi/bin \
  "$DENO_INSTALL/bin" \
  "/home/jack/.bin"

# Generated for envman. Do not edit.
test -s "$HOME/.config/envman/load.fish"; and source "$HOME/.config/envman/load.fish"

eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

function chris_say
  notify-send -i "/home/jack/Pictures/chris.svg" "$argv"
end

function chris_gag
  chris_say "hello jack"
  read
  chris_say "it is me .. chris hardy"
  read
  chris_say "i love bombardier recreational products"
end

function posix-source
  for i in (cat $argv)
    set arr (echo $i |tr = \n)
    set -gx $arr[1] $arr[2]
  end
end

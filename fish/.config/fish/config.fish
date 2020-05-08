set EDITOR vim

status --is-interactive; and pyenv init - | source
status --is-interactive; and pyenv virtualenv-init - | source

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

function brm --wraps='xrandr --output eDP-1 --brightness 1.5' --wraps='xrandr --output eDP-1 --brightness 2' --description 'alias brm xrandr --output eDP-1 --brightness 2'
  xrandr --output eDP-1 --brightness 2 $argv
        
end

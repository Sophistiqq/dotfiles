function hlconf --wraps='cd ~/.config/hypr && nvim' --wraps='cd ~/.config/hypr && nvim/hyprland.conf' --wraps='cd ~/.config/hypr && nvim hyprland.conf' --description 'alias hlconf cd ~/.config/hypr && nvim hyprland.conf'
  cd ~/.config/hypr && nvim hyprland.conf $argv
        
end

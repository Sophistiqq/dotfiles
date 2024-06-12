if status is-interactive
    # Commands to run in interactive sessions can go here
end
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

abbr -a -- abbrsave 'abbr >> ~/.config/fish/config.fish'
abbr -a -- ff fastfetch
abbr -a -- nvconf 'cd ~/.config/nvim/ && nvim'
abbr -a -- hlconf 'cd ~/.config/hypr/ && nvim hyprland.conf'


function fish_greeting
  fastfetch
end
abbr -a -- ghce 'gh copilot explain '
abbr -a -- ghcs 'gh copilot suggest '

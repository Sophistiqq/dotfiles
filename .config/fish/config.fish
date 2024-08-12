if status is-interactive
    # Commands to run in interactive sessions can go here
end
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH

abbr -a -- abbrsave 'abbr >> ~/.config/fish/config.fish'
abbr -a -- ff fastfetch
abbr -a -- nvconf 'cd ~/.config/nvim/ && nvim'
abbr -a -- hlconf 'cd ~/.config/hypr/ && nvim hyprland.conf'
abbr -a -- db "mariadb -u roi -p ads_db"
abbr -a -- startdb "sudo systemctl start mariadb"
function fish_greeting
end
abbr -a -- ghce 'gh copilot explain '
abbr -a -- ghcs 'gh copilot suggest '

# add to ~/.config/fish/config.fish
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

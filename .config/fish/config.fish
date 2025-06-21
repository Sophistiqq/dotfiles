if status is-interactive
end
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
set -g fish_greeting ""
abbr -a -- abbrsave 'abbr >> ~/.config/fish/config.fish'
abbr -a -- ff fastfetch
abbr -a -- nvconf 'cd ~/.config/nvim/ && nvim'
abbr -a -- hlconf 'cd ~/.config/hypr/ && nvim hyprland.conf'
abbr -a -- db "mariadb -u roi -p ads_db"
abbr -a -- startdb "sudo systemctl start mariadb"
abbr -a -- ghce 'gh copilot explain '
abbr -a -- ghcs 'gh copilot suggest '
# add to ~/.config/fish/config.fish
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# run setvtrgb
function setvtrgb
    if test -n "$TMUX"
        tmux set-option -g default-terminal "screen-256color"
    else
        set -gx TERM "xterm-256color"
    end
end

zoxide init fish | source

starship init fish | source
starship preset jetpack -o ~/.config/jetpack.toml

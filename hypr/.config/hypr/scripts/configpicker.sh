#!/usr/bin/env bash

# Config picker: browse dotfiles + ~/.config, open the selection in nvim
# inside a fresh alacritty window.

dotfiles="$HOME/dotfiles"
config_dir="$HOME/.config"

list_configs() {
    find "$dotfiles" "$config_dir" -type f \
        -not -path "*/node_modules/*" \
        -not -path "*/lazy-lock.json" \
        -not -path "*/.git/*" \
        -not -path "*/build/*" \
        -not -path "*/nvim_backup/*" \
        -not -name "*.lock" \
        -not -name "*.log" \
        -not -name "*.png" -not -name "*.jpg" -not -name "*.jpeg" \
        -not -name "*.gif" -not -name "*.webp" -not -name "*.svg" \
        -not -name "*.woff*" -not -name "*.ttf" -not -name "*.otf" \
        -not -name "*.so" -not -name "*.a" -not -name "*.o" \
        -not -name "*.pyc" -not -name "*.bin" -not -name "*.db" \
        2>/dev/null | while read -r f; do
            realpath -q "$f"
        done | sort -u
}

chosen="$(list_configs | sed "s|$HOME|~|" | rofi -dmenu -p "config" -matching fuzzy)"

[ -n "$chosen" ] || exit 1

path="${chosen/#\~/$HOME}"
alacritty -e nvim "$path"

#!/bin/sh

# wrapper to launch neovim inside tmux

nv_cmd="/usr/bin/nvim"

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/gnvim"
config_file="${config_dir}/configrc"

# loading the config here means the user can overwrite any of the functions
if [ -f "$config_file" ]; then
    . "$config_file"
else
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi
    cat << __HEREDOC__ >> "$config_file"
# vim: ft=sh
# gnvim wrapper config file

# terminal command
term_cmd="x-terminal-emulator"

# neovim command
nv_cmd="${nv_cmd}"
__HEREDOC__
fi

if [ -n "${1}" ]; then
    vimcmd="$nv_cmd ${1}"
else
    vimcmd="$nv_cmd"
fi

if [ -z "$TMUX" ] ;then
    ID=$(tmux ls | grep nvim | cut -d: -f1) # get the id of a detached session
    if [ -z "$ID" ] ;then
        tmux new-session -s "nvim" "${vimcmd}" \; attach # if not existing, create one
    else
        tmux attach-session -t "$ID" # attach to existing
        tmux new-window "${vimcmd}" # if existing, open new tab
    fi
fi

#!/bin/sh

# wrapper to launch neovim inside tmux

s_id="nvim"

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

# tmux session id
s_id="${s_id}"
__HEREDOC__
fi

ID=""
case "$1" in
    --session-id)
        shift
        ID="$1"
        shift
        ;;
esac

if [ -n "${1}" ]; then
    vimcmd="$nv_cmd ${1}"
else
    vimcmd="$nv_cmd"
fi

if [ -z "$TMUX" ] ;then
    # id of session
    ID=$(tmux ls | grep "$s_id" | cut -d: -f1)
    if [ -z "$ID" ] ;then
        # if not existing, create one
        ID="$s_id"
        tmux new-session -s "$ID" "${vimcmd}" \; attach
    else
        # attach to existing
        tmux attach-session -t "$ID"
        # new "tab"
        tmux new-window "${vimcmd}"
    fi
fi

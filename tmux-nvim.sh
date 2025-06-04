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

myname="${0##*/}"

ID=""
use_id=""
case "$1" in
    --session-id)
        shift
        use_id="$1"
        shift
        ;;
    help|-h|--help)
        printf '%s\n\t%s\n' "${myname}:" \
                            "nvim tmux wrapper"
        printf '%s\n\t%s\n' "Version:" "@VERSION@"
        printf '%s\n\t%s\n' "Usage:" \
                            "${myname} -h | [ --session-id NAME ] [ nvim flags and files ]"
        printf '%s\n\t%s\n' "    -h" \
                            "print out this help message, 'help' and '--help' supported"
        printf '%s\n\t%s\n' "    --session-id NAME" \
                            "tmux session name, has precedence over config specified one"
        exit 0
        ;;
esac

if [ "$#" -gt 0 ]; then
    vimcmd="$nv_cmd ${*}"
else
    vimcmd="$nv_cmd"
fi

if [ -z "$TMUX" ] ;then
    # id of session
    ID=$(tmux ls | grep "$s_id" | cut -d: -f1)
    if [ -z "$ID" ] ;then
        # if not existing, create one
        if [ -n "$use_id" ]; then
            ID="$use_id"
        else
            ID="$s_id"
        fi
        tmux new-session -s "$ID" "${vimcmd}" \; attach
    else
        # attach to existing
        tmux attach-session -t "$ID"
        # new "tab"
        tmux new-window "${vimcmd}"
    fi
fi

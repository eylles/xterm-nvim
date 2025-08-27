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
    cat << __HEREDOC__ > "$config_file"
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

ID="$s_id"
case "$1" in
    id|-s|--session-id)
        shift
        ID="$1"
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

if [ -z "$TMUX" ] ;then
    if ! tmux has-session -t "$ID" 2>/dev/null ;then
        # create session
        tmux new-session -s "$ID" "${nv_cmd}" "$@"
    else
        # attach to existing
        tmux attach-session -t "$ID"
        # new "tab"
        tmux new-window "${nv_cmd}" "$@"
    fi
fi

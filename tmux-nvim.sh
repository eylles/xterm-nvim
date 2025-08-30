#!/bin/sh

# wrapper to launch neovim inside tmux

class="nvim"

nv_cmd="/usr/bin/nvim"

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/gnvim"
config_file="${config_dir}/configrc"

if [ ! -f "$config_file" ]; then
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

# gnvim class
class="${class}"

# do not use tmux for regular operation
# setting this to anything will take effect
no_tmux=""
__HEREDOC__
fi

# loading the config here means the default config is already present and the user is not able to
# overwrite anything defined after this point.
. "$config_file"

myname="${0##*/}"

ID="$class"
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
                            "print out this help message, 'help' and '--help' are supported too"
        printf '%s\n\t%s\n' "    --session-id NAME" \
                            "tmux session name, has precedence over config specified one"
        printf '\n'
        printf '%s\n\t%s\n' "Config:" "$config_file"
        exit 0
        ;;
esac

if [ -z "$TMUX" ] ;then
    if ! tmux has-session -t "$ID" 2>/dev/null ;then
        # create session
        tmux new-session -s "$ID" "${nv_cmd}" "$@"
    else
        # new "tab" on existing
        tmux new-window -t "$ID" "${nv_cmd}" "$@"
    fi
fi

#!/bin/sh

term_cmd="x-terminal-emulator"
no_tmux=""
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
nv_cmd="/usr/bin/nvim"

# tmux session id
s_id="nvim"

# do not use tmux for regular operation
# setting this to anything will take effect
no_tmux=""
__HEREDOC__
fi

myname="${0##*/}"

# cuz $UID is not POSIX ¯\_(ツ)_/¯
# but it may be defined in the environment
if [ -z "$UID" ]; then
  # result of: id -u $USER
  UserID=$(id -u "$USER")
else
  UserID="$UID"
fi

class="gnvim"
use_class=""
case "$1" in
    --class)
        shift
        use_class="$1"
        class="$1"
        shift
        ;;
    help|-h|--help)
        printf '%s\n\t%s\n' "${myname}:" \
                            "nvim terminal wrapper"
        printf '%s\n\t%s\n' "Version:" "@VERSION@"
        printf '%s\n\t%s\n' "Usage:" \
                            "${myname} -h | [ --class NAME ] [ nvim flags and files ]"
        printf '%s\n\t%s\n' "    -h" \
                            "print out this help message, 'help' and '--help' supported"
        printf '%s\n\t%s\n\t%s%s\n' \
                            "    --class NAME" \
                            "sets terminal '-name' and '-T' flags to NAME, sets tmux-nvim" \
                            "--session-id to NAME, sets runfile as " \
                            "'/var/run/user/\$ID/gnvim/NAME.lock'"
        exit 0
        ;;
esac

run_dir="/var/run/user/${UserID}/${class}"
run_file="${run_dir}/${class}.lock"
p_file="${run_dir}/${class}.pipe"

# unix command line like booleans

# Type: int
# value: 0
b_true=0
# Type: int
# value: 1
b_false=1

cleanup() {
    rm "$run_file"
}

trap cleanup EXIT

if [ -f "$run_file" ]; then
    hasterm="$b_true"
    date +"[%F %T]: ${myname} called." >> "$run_file"
else
    hasterm="$b_false"
    if [ ! -d "$run_dir" ]; then
        mkdir -p "$run_dir"
    fi
    date +"[%F %T]: ${myname} called." > "$run_file"
fi

if [ ! -f "$run_file" ]; then
    exit 1
else
    if [ "$hasterm" -eq "$b_true" ]; then
        if [ -z "$no_tmux" ]; then
            exec tmux-nvim "$@"
        else
            exec nvim --server "$p_file" --remote-send "<C-\\><C-N>:tabedit ${*}<CR>"
        fi
    else
        if [ -z "$no_tmux" ]; then
            if [ -n "$use_class" ]; then
                c="$use_class"
                $term_cmd -name "$c" -title "$c" -e tmux-nvim --session-id "$c" "$@"
            else
                $term_cmd -name "$class" -e tmux-nvim "$@"
            fi
        else
            if [ -n "$use_class" ]; then
                c="$use_class"
                $term_cmd -name "$c" -title "$c" -e $nv_cmd --listen "$p_file" "$@"
            else
                $term_cmd -name "$class" -e nv_cmd --listen "$p_file" "$@"
            fi
        fi
    fi
    cleanup
fi

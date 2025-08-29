#!/bin/sh

behaviour="classic"

TMP_DIR="/tmp/vim-anywhere"

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/vim-anywhere"
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
# vim anywhere config

# vim anywhere behaviour: classic simple
# classic: the behaviour of the classic vim anywhere script, a tmp dir is created and every
#          instance of vim-anywhere creates a new file inside that directory.
# simple:  a simpler behaviour, no special tmp dir is created, instead every time an instance of
#          vim-anywhere runs a tmp file is created, once vim exits the tmp file is deleted.
behaviour="${behaviour}"

# the location for the tmp dir
TMP_DIR="${TMP_DIR}"
__HEREDOC__
fi

TMP_FILE=""

case "$behaviour" in
    classic)
        TMP_FILE="${TMP_DIR}/doc-$(date +"%Y%m%d%H%M%S")"
        ;;
    simple)
        TMP_FILE="${TMP_DIR}/doc"
        ;;
esac

lockfile="/tmp/vim-anywhere.lock"

# start vim in insert mode
vimopts="+star"

clipboard_to_file () {
    case "$XDG_SESSION_TYPE" in
        x11)
            xclip -o -selection clipboard > "$TMP_FILE"
            ;;
        wayland)
            wl-paste > "$TMP_FILE"
            ;;
    esac
}

type_file () {
    # delay in milliseconds
    d_time="6"
    case "$XDG_SESSION_TYPE" in
        x11)
            xdotool type --delay "$d_time" "$(cat $TMP_FILE)"
            ;;
        wayland)
            wtype -d "$d_time" "$(cat $TMP_FILE)"
            ;;
    esac
}

myname="${0##*/}"
mypid="${$}"

if [ -f "$lockfile" ]; then
    exit 1
else
    printf '%s\n' "$mypid" > "$lockfile"
fi

if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
fi

case "$1" in
    -c|clipboard)
        shift
        clipboard_to_file
        ;;
    help|-h|--help)
        printf '%s\n\t%s\n' "${myname}:" \
                            "nvim window from anywhere"
        printf '%s\n\t%s\n' "Version:" "@VERSION@"
        printf '%s\n\t%s\n' "Usage:" \
                            "${myname} -h | [ -c ]"
        printf '%s\n\t%s\n' "    -h" \
                            "print out this help message, 'help' and '--help' are supported too"
        printf '%s\n\t%s\n' "    -c" \
                            "copy clipboard contents to vim-anywhere tmp file"
        exit 0
        ;;
esac

gnvim "--class" "GVim-Anywhere" "$vimopts" "$TMP_FILE"

# yeh some delay for your window to recover focus...
sleep 0.6
type_file

case "$behaviour" in
    simple)
        rm -f "$TMP_FILE"
        ;;
esac

rm "$lockfile"

#!/bin/sh

TMP_FILE="/tmp/vim-anywhere"
: > "$TMP_FILE"
chmod 600 "$TMP_FILE"

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
    case "$XDG_SESSION_TYPE" in
        x11)
            xdotool type "$(cat $TMP_FILE)"
            ;;
        wayland)
            wtype "$(cat $TMP_FILE)"
            ;;
    esac
}

myname="${0##*/}"

case "$1" in
    -c|clipboard)
        shift
        clipboard_to_file
        ;;
    help|-h|--help)
        printf '%s\n\t%s\n' "${myname}:" \
                            "nvim window from anywhere"
        printf '%s\n\t%s\n' "Usage:" \
                            "${myname} -h | [ -c ]"
        printf '%s\n\t%s\n' "    -h" \
                            "print out this help message, 'help' and '--help' supported"
        printf '%s\n\t%s\n' "    -c" \
                            "copy clipboard contents to vim-anywhere tmp file"
        exit 0
        ;;
esac

gnvim "--class" "GVim" "$vimopts" "$TMP_FILE"

# xclip -selection clipboard "$TMP_FILE"

# yeh some delay for your window to recover focus...
sleep 0.6
type_file

rm "$TMP_FILE"

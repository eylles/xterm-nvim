#!/bin/sh

TMP_FILE="/tmp/vim-anywhere"
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

rm -f "$TMP_FILE" "$lockfile"

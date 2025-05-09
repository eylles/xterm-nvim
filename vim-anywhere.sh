#!/bin/sh

TMP_FILE="/tmp/vim-anywhere"
: > "$TMP_FILE"
chmod 600 "$TMP_FILE"

# start vim in insert mode
vimopts="+star"

case "$1" in
    -c|clipboard)
        shift
        xclip -o -selection clipboard > "$TMP_FILE"
        use_clipboard="true"
        ;;
esac

gnvim "--class" "GVim" "$vimopts" "$TMP_FILE"

# xclip -selection clipboard "$TMP_FILE"

# yeh some delay for your window to recover focus...
sleep 0.6
xdotool type "$(cat $TMP_FILE)"

rm "$TMP_FILE"

#!/bin/sh

behaviour="classic"

TMP_DIR="/tmp/vim-anywhere"
DEF_FT="txt"

# char type delay in milliseconds
type_delay="6"
focus_delay="0.6"

class="GVim-Anywhere"

insertmode_start=""

config_dir="${XDG_CONFIG_HOME:-${HOME}/.config}/vim-anywhere"
config_file="${config_dir}/configrc"

if [ ! -f "$config_file" ]; then
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi
    cat << __HEREDOC__ > "$config_file"
# vim: ft=sh
# vim anywhere config

# vim anywhere behaviour: classic simple
# classic: the behaviour of the classic vim anywhere script, a tmp dir is created and every
#          instance of vim-anywhere creates a new file inside that directory.
# simple:  a simpler behaviour, every time an instance of vim-anywhere runs a tmp file is created
#          with the same static name, once vim exits the tmp file is deleted.
behaviour="${behaviour}"

# the location for the tmp dir
TMP_DIR="${TMP_DIR}"

# default file type extension, we do no checking of this whatsoever, just pass your preferred file
# type extension for creating of the file, by default that is "txt" to create plain text files, but
# you may change it to whatever you want, like "md" for markdown or "py" for python, "c" for c, you
# get the idea.
DEF_FT="${DEF_FT}"

# delay in milliseconds between typing of characters, with the default of 6 milliseconds a word that
# is 5 characters long will take 30 milliseconds to be typed out.
type_delay="${type_delay}"

# the delay in seconds between gnvim being closed to the contents of the tmp file being typed out,
# this is the time you got to click into your desired text field window to ensure your text will be
# typed out in the correct place, the "0.6" default gives you slightly more than half second to
# react, also assumes that the sleep(1) utility in your system supports float values as all modern
# core unix utilities implementations do nowadays.
focus_delay="${focus_delay}"

# the class option for vim-anywhere, this is passed on to gnvim(1) which will set the terminal
# command class and title to this very same string, this should make it possible to add special
# rules for your window manager, given it has such functionality, to make the vim-anywhere terminal
# window into an "ontop" window with your desired dimensions and any other setting your window
# manager and compositor are able to apply based on the name title of the window alone.
class="${class}"

# this option controls werether or not to initiate the neovim instance of vim-anywhere in insert
# mode, leave this option empty to start in normal mode, write any text inside this to start in
# insert mode, whichever text is written is of no relevance as all that is checked is werether the
# variable is empty or not.
insertmode_start="${insertmode_start}"
__HEREDOC__
fi

# loading the config here means the default config is already present and the user is not able to
# overwrite anything defined after this point.
. "$config_file"

TMP_FILE=""

case "$behaviour" in
    classic)
        TMP_FILE="${TMP_DIR}/doc-$(date +"%Y%m%d%H%M%S").${DEF_FT}"
        ;;
    simple)
        TMP_FILE="${TMP_DIR}/doc.${DEF_FT}"
        ;;
esac

lockfile="/tmp/vim-anywhere.lock"

vimopts=""
if [ -n "$insertmode_start" ]; then
    # start vim in insert mode
    vimopts="+star"
fi

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
            xdotool type --delay "$type_delay" "$(cat $TMP_FILE)"
            ;;
        wayland)
            wtype -d "$type_delay" "$(cat $TMP_FILE)"
            ;;
    esac
}

myname="${0##*/}"
mypid="${$}"

is_instance () {
    ps ax -o'pid=,cmd=' \
        | sed 's/^ *//' \
        | awk \
            -v pid="$1" \
            -v name="$myname" \
            '
                BEGIN { found = 0 }
                $1 == pid && $0 ~ name { found = 1 }
                END { if (!found) exit 1 }
            '
}

if [ -f "$lockfile" ] && is_instance "$(head $lockfile)" ; then
    exit 1
else
    printf '%s\n' "$mypid" > "$lockfile"
fi

if [ ! -d "$TMP_DIR" ]; then
    mkdir -p "$TMP_DIR"
fi

case "$1" in
    clipboard|-c|--clipboard)
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
        printf '\n'
        printf '%s\n\t%s\n' "Config:" "$config_file"
        exit 0
        ;;
esac

gnvim "--class" "$class" "$vimopts" "$TMP_FILE"

# yeh some delay for your window to recover focus...
sleep "$focus_delay"
type_file

case "$behaviour" in
    simple)
        rm -f "$TMP_FILE"
        ;;
esac

rm "$lockfile"

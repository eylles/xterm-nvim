#!/bin/sh

uridecode() {
    python3 - "$@" <<'___HEREDOC'
from urllib.parse import unquote, urlparse
from sys import argv
for arg in argv[1:]:
    print(unquote(urlparse(arg).path))
___HEREDOC
}

case "$1" in
    help|h|-h|--help)
        myname="${0##*/}"
        printf '%s\n\t%s\n' "${myname}:" "nvim uri scheme handler"
        printf '%s\n\t%s\n' "Version:" "@VERSION@"
        printf '\n'
        printf '%s\n' "this script is not intended to be ran directly by the user but rather"
        printf '%s\n' "to be called by it's associated desktop file, ${myname}.desktop when"
        printf '%s\n' "some program requests to handle the associated uri scheme, by default:"
        printf '%s\n' "    nvim://"
        printf '%s\n' "    vim://"
        exit 0
        ;;
esac

# Parse the nvim:// URL (e.g. nvim://open?file=/path/to/file&line=123)

# URI can come in one of the following forms:
#
# With only a '?' preceding the keyword
#     vim://open?file=/path/to/file&line=123
#     vim://open?url=file:///path/to/file&line=123
#     vim://open?uri=file:///path/to/file&line=123
#
# With '/?' preceding the keyword
#     vim://open/?file=/path/to/file&line=123
#     vim://open/?url=file:///path/to/file&line=123
#     vim://open/?uri=file:///path/to/file&line=123
uri="$1"
case "$uri" in
    *line=*)
        line="${uri##*&line=}"
        ;;
    *)
        line="${uri##*://open?file=*}"
        line="${uri##*://open?url=*}"
        line="${uri##*://open?uri=*}"

        line="${uri##*://open/?file=*}"
        line="${uri##*://open/?url=*}"
        line="${uri##*://open/?uri=*}"
        ;;
esac
line="${line:-1}"

uri="${uri##*://open?file=}"
uri="${uri##*://open?url=}"
uri="${uri##*://open?uri=}"

uri="${uri##*://open/?file=}"
uri="${uri##*://open/?url=}"
uri="${uri##*://open/?uri=}"


uri="${uri%%&line=*}"
file=$(uridecode "${uri}")

gnvim "+$line" "$file"

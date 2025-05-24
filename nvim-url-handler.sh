#!/bin/sh

uridecode() {
    python3 - "$@" <<'___HEREDOC'
from urllib.parse import unquote, urlparse
from sys import argv
for arg in argv[1:]:
    print(unquote(urlparse(arg).path))
___HEREDOC
}

# Parse the nvim:// URL (e.g. nvim://open?file=/path/to/file&line=123)
uri="$1"
case "$uri" in
    *line=*)
        line="${uri##*&line=}"
        ;;
    *)
        line="${uri##nvim://open?file=*}"
        ;;
esac
line="${line:-1}"
uri="${uri##nvim://open?file=}"
uri="${uri%%&line=*}"
file=$(uridecode "${uri}")

gnvim "+$line" "$file"

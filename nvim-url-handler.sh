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
        line="${uri##*vim://open?file=*}"
        line="${uri##*vim://open?url=*}"
        line="${uri##*vim://open?uri=*}"

        line="${uri##*vim://open/?file=*}"
        line="${uri##*vim://open/?url=*}"
        line="${uri##*vim://open/?uri=*}"
        ;;
esac
line="${line:-1}"

uri="${uri##*vim://open?file=}"
uri="${uri##*vim://open?url=}"
uri="${uri##*vim://open?uri=}"

uri="${uri##*vim://open/?file=}"
uri="${uri##*vim://open/?url=}"
uri="${uri##*vim://open/?uri=}"


uri="${uri%%&line=*}"
file=$(uridecode "${uri}")

gnvim "+$line" "$file"

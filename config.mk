# Prefix for install
PREFIX = ${HOME}/.local

# location of binaries
BIN_LOC = $(DESTDIR)${PREFIX}/bin
# location of desktop files
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications

# uri schemes to handle
URI_SCHEMES = nvim vim

.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
.PHONY: all install uninstall clean

all: gnvim tmux-nvim

gnvim:
	cp gnvim.sh gnvim

tmux-nvim:
	cp tmux-nvim.sh tmux-nvim

install: all
	chmod 755 gnvim
	chmod 755 tmux-nvim
	mkdir -p $(BIN_LOC)
	cp -v gnvim $(BIN_LOC)/
	cp -v tmux-nvim $(BIN_LOC)/

install-desktop:
	@echo "INSTALL gnvim.desktop"
	mkdir -p $(DESK_LOC)
	cp gnvim.desktop $(DESK_LOC)/

install-all: install install-desktop

uninstall:
	rm -vf $(BIN_LOC)/gnvim
	rm -vf $(LIB_LOC)/tmux-nvim
	rm -vf $(DESK_LOC)/gnvim.desktop

clean:
	rm -v gnvim tmux-nvim

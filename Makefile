.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
.PHONY: all install uninstall clean

all: gnvim tmux-nvim nvim-url-handler vim-anywhere

gnvim:
	cp gnvim.sh gnvim

tmux-nvim:
	cp tmux-nvim.sh tmux-nvim

nvim-url-handler:
	cp nvim-url-handler.sh nvim-url-handler

vim-anywhere:
	cp vim-anywhere.sh vim-anywhere

install: all
	chmod 755 gnvim
	chmod 755 tmux-nvim
	chmod 755 nvim-url-handler
	chmod 755 vim-anywhere
	mkdir -p $(BIN_LOC)
	cp -vf gnvim $(BIN_LOC)/
	cp -vf tmux-nvim $(BIN_LOC)/
	cp -vf nvim-url-handler $(BIN_LOC)/
	cp -vf vim-anywhere $(BIN_LOC)/

install-desktop:
	@echo "INSTALL gnvim.desktop"
	mkdir -p $(DESK_LOC)
	cp -f gnvim.desktop $(DESK_LOC)/
	cp -f nvim-url-handler.desktop $(DESK_LOC)/
	xdg-mime default nvim-url-handler.desktop x-scheme-handler/nvim
	update-desktop-database $(DESK_LOC)

install-all: install install-desktop

uninstall:
	rm -vf $(BIN_LOC)/gnvim
	rm -vf $(LIB_LOC)/tmux-nvim
	rm -vf $(LIB_LOC)/vim-anywhere
	rm -vf $(DESK_LOC)/gnvim.desktop
	rm -vf $(DESK_LOC)/nvim-url-handler.desktop

clean:
	rm -vf gnvim tmux-nvim nvim-url-handler vim-anywhere

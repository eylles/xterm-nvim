.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
.PHONY: all install uninstall clean
URI_SCHEMES = nvim vim
VERSION = 0.0.0

all: gnvim tmux-nvim nvim-url-handler vim-anywhere

gnvim:
	sed "s|@VERSION@|$(VERSION)|" gnvim.sh > gnvim
	chmod 755 gnvim

tmux-nvim:
	sed "s|@VERSION@|$(VERSION)|" tmux-nvim.sh > tmux-nvim
	chmod 755 tmux-nvim

nvim-url-handler:
	sed "s|@VERSION@|$(VERSION)|" nvim-url-handler.sh > nvim-url-handler
	chmod 755 nvim-url-handler

nvim-url-handler.desktop:
	cp nvim-url-handler.desktop.in nvim-url-handler.desktop
	for scheme in $(URI_SCHEMES); do \
		sed -i "/^MimeType=/ s/$$/x-scheme-handler\/$${scheme};/" nvim-url-handler.desktop; \
	done

vim-anywhere:
	sed "s|@VERSION@|$(VERSION)|" vim-anywhere.sh > vim-anywhere
	chmod 755 vim-anywhere

install: all
	mkdir -p $(BIN_LOC)
	cp -vf gnvim $(BIN_LOC)/
	cp -vf tmux-nvim $(BIN_LOC)/
	cp -vf nvim-url-handler $(BIN_LOC)/
	cp -vf vim-anywhere $(BIN_LOC)/

install-desktop: nvim-url-handler.desktop
	@echo "INSTALL gnvim.desktop"
	mkdir -p $(DESK_LOC)
	cp -f gnvim.desktop $(DESK_LOC)/
	cp -f nvim-url-handler.desktop $(DESK_LOC)/
	for scheme in $(URI_SCHEMES); do \
		xdg-mime default nvim-url-handler.desktop "x-scheme-handler/$${scheme}"; \
	done
	update-desktop-database $(DESK_LOC)

install-all: install install-desktop

uninstall:
	rm -vf $(BIN_LOC)/gnvim
	rm -vf $(LIB_LOC)/tmux-nvim
	rm -vf $(LIB_LOC)/vim-anywhere
	rm -vf $(DESK_LOC)/gnvim.desktop
	rm -vf $(DESK_LOC)/nvim-url-handler.desktop

clean:
	rm -vf gnvim tmux-nvim nvim-url-handler vim-anywhere nvim-url-handler.desktop

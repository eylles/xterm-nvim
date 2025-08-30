.POSIX:
PREFIX = ${HOME}/.local
BIN_LOC = $(DESTDIR)${PREFIX}/bin
MANPREFIX = $(DESTDIR)$(PREFIX)/share/man
DESK_LOC = $(DESTDIR)$(PREFIX)/share/applications
.PHONY: all install uninstall clean
URI_SCHEMES = nvim vim
VERSION = 0.1.0

include config.mk

all: gnvim tmux-nvim nvim-url-handler vim-anywhere
	sed "s|@VERSION@|$(VERSION)|" xterm-nvim.7.in > xterm-nvim.7

gnvim:
	sed "s|@VERSION@|$(VERSION)|" gnvim.sh > gnvim
	chmod 755 gnvim
	sed "s|@VERSION@|$(VERSION)|" gnvim.1.in > gnvim.1

tmux-nvim:
	sed "s|@VERSION@|$(VERSION)|" tmux-nvim.sh > tmux-nvim
	chmod 755 tmux-nvim
	sed "s|@VERSION@|$(VERSION)|" tmux-nvim.1.in > tmux-nvim.1

nvim-url-handler:
	sed "s|@VERSION@|$(VERSION)|;s|@SCHEMES@|$(URI_SCHEMES)|" \
		nvim-url-handler.sh > nvim-url-handler
	chmod 755 nvim-url-handler
	sed "s|@VERSION@|$(VERSION)|;s|@SCHEMES@|$(URI_SCHEMES)|" \
		nvim-url-handler.1.in > nvim-url-handler.1

nvim-url-handler.desktop:
	cp nvim-url-handler.desktop.in nvim-url-handler.desktop
	for scheme in $(URI_SCHEMES); do \
		sed -i "/^MimeType=/ s/$$/x-scheme-handler\/$${scheme};/" nvim-url-handler.desktop; \
	done

vim-anywhere:
	sed "s|@VERSION@|$(VERSION)|" vim-anywhere.sh > vim-anywhere
	chmod 755 vim-anywhere
	sed "s|@VERSION@|$(VERSION)|" vim-anywhere.1.in > vim-anywhere.1

install: all
	mkdir -p $(BIN_LOC)
	cp -vf gnvim $(BIN_LOC)/
	cp -vf tmux-nvim $(BIN_LOC)/
	cp -vf nvim-url-handler $(BIN_LOC)/
	cp -vf vim-anywhere $(BIN_LOC)/
	mkdir -p $(MANPREFIX)/man1
	cp -vf gnvim.1 $(MANPREFIX)/man1/
	cp -vf tmux-nvim.1 $(MANPREFIX)/man1/
	cp -vf nvim-url-handler.1 $(MANPREFIX)/man1/
	cp -vf vim-anywhere.1 $(MANPREFIX)/man1/
	mkdir -p $(MANPREFIX)/man7
	cp -vf xterm-nvim.7 $(MANPREFIX)/man7/


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
	rm -vf $(BIN_LOC)/tmux-nvim
	rm -vf $(BIN_LOC)/vim-anywhere
	rm -vf $(DESK_LOC)/gnvim.desktop
	rm -vf $(DESK_LOC)/nvim-url-handler.desktop
	rm -vf $(MANPREFIX)/man1/gnvim.1
	rm -vf $(MANPREFIX)/man1/tmux-nvim.1
	rm -vf $(MANPREFIX)/man1/nvim-url-handler.1
	rm -vf $(MANPREFIX)/man1/vim-anywhere.1
	rm -vf $(MANPREFIX)/man7/xterm-nvim.7

clean:
	rm -vf gnvim tmux-nvim nvim-url-handler vim-anywhere
	rm -vf nvim-url-handler.desktop
	rm -vf gnvim.1 tmux-nvim.1 nvim-url-handler.1 vim-anywhere.1 xterm-nvim.7

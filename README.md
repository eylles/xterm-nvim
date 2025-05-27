# xterm-nvim

A pair of shell wrappers with tmux to provide a sessioned "tabbed" (neo)vim client

<img src="./Screenshot.png">


## install

```sh
make clean install-all
```


## notes

### terminal wrapper

By default the script will use the `x-terminal-emulator` program, which is a debianism, usually a
symlink pointing to an appropriate wrapper script that does the work of normalizing the command line
to provide scripts an interface that is compatible with the common [xterm](https://manpages.debian.org/unstable/xterm/xterm.1.en.html)
parameter flags and behaviours for example the [gnome-terminal.wrapper](https://sources.debian.org/src/gnome-terminal/3.56.1-1/debian/gnome-terminal.wrapper/)
however you may not need to build your own x-terminal-emulator wrapper as by policy debian will
provide such wrapper for the terminal emulators that DO need it, you can check from the following
list of terminals that provide the x-terminal-emulator interface in debian to simply yank the needed
wrapper: [x-terminal-emulator list](https://packages.debian.org/sid/x-terminal-emulator)

As such the `gnvim` script expects x-terminal-emulator to exist, have the same argument handling
behaviour as an xterm and to support the following flags:

|flag|use|
|----|---|
|-e|execute command|
|-name|change terminal class or profile, set the WM_CLASS(STRING)|
|-title|change terminal title, set the WM_NAME(STRING)|

Both gnvim and tmux-nvim will generate a default config upon first run.

### help output

The 3 scripts support the `-h` flag to show help messages, consult them before using.

### vim-anywhere

Decided to roll out my own vim-anywhere implementation inspired on the original one with quite some
changes, for it to work your terminal emulator or wrapper must support the `-name` and `-title` flags
as by convenience with those you can set up rules in your window manager to to always treat the
terminal window as a floating window (if you use a tiling window manager) to be always on top, the
name and class passed onto the vim anywhere terminal is `GVim`

#### wayland support

In addition to the previous requirements you will need these:
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard)
- [wtype](https://github.com/atx/wtype)

### nvim-url-handler

This provides support for the yet to be officialized `nvim://` uri schema from:
[neovim #34102](https://github.com/neovim/neovim/issues/34102)

The script in addition to coreutils requires a python interpreter for uri decoding and programs
`xdg-mime` from `xdg-utils` and `update-desktop-database` from `desktop-file-utils`

You can modify which uri schemes will be handled by the script at install time, just edit the
config.mk file then install as normal, for example:
```sh
URI_SCHEMES = nvim vim editor
```
to add support for a generic editor uri scheme in the spirit of debian.

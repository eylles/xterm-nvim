# xterm-nvim

A pair of shell wrappers with tmux to provide a sessioned "tabbed" (neo)vim client

<img src="./Screenshot.png">


## install

```sh
make install
```


## notes

### terminal wrapper

By default the script will use the `x-terminal-emulator` program, which is a debianism, usually a
symlink pointing to an appropriate wrapper script that does the work of normalizing the command line
to provide scripts an interface that is compatible with the common [xterm](https://manpages.debian.org/unstable/xterm/xterm.1.en.html)
parameter flags and behaviours for example the [gnome-terminal.wrapper](https://sources.debian.org/src/gnome-terminal/3.56.1-1/debian/gnome-terminal.wrapper/)
as such the `gnvim` script expects x-terminal-emulator to exist, have the same argument handling
behaviour as an xterm and to support the following flags:

|flag|use|
|----|---|
|-e|execute command|
|-name|change terminal class or profile, set the WM_CLASS(STRING)|
|-T|change terminal title, set the WM_NAME(STRING)|

Both gnvim and tmux-nvim will generate a default config upon first run.

### vim-anywhere

Decided to roll out my own vim-anywhere implementation inspired on the original one with quite some
changes, for it to work your terminal emulator or wrapper must support the `-name` and `-T` flags
as by convenience with those you can set up rules in your window manager to to always treat the
terminal window as a floating window (if you use a tiling window manager) to be always on top, the
name and class passed onto the vim anywhere terminal is `GVim`

#### wayland support

In addition to the previous requirements you will need these:
- [wl-clipboard](https://github.com/bugaevc/wl-clipboard)
- [wtype](https://github.com/atx/wtype)

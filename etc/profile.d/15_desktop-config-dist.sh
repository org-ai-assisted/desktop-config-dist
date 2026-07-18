#!/bin/sh

## Copyright (C) 2025 - 2026 ENCRYPTED SUPPORT LLC <adrelanos@whonix.org>
## See the file COPYING for copying conditions.

if [ -f '/usr/share/qubes/marker-vm' ]; then
  ## https://github.com/QubesOS/qubes-issues/issues/3366
  true "$0: Qubes does not support Wayland yet. Not setting GDK_BACKEND and QT_QPA_PLATFORM, ok."

  ## Fix theming of Qt apps.
  export QT_QPA_PLATFORMTHEME='lxqt'
else
  ## Fix wlroots glitches with virtualized graphics
  if [ "$(systemd-detect-virt 2>/dev/null)" != 'none' ]; then
    export WLR_RENDERER='pixman'
  fi

  ## Prefer Wayland but keep X11 (XWayland) as a fallback. The backends are
  ## tried left to right, so apps that support Wayland still use it, while apps
  ## that do not support Wayland -- or that need XWayland, such as some root GUI
  ## apps launched from the menu (partition editor, firewall settings, status
  ## checker) -- fall back to X11 instead of failing to open any window at all.
  ## Without a fallback (a bare 'wayland') those apps abort with no window.

  ## gtk3: comma-separated backend list.
  export GDK_BACKEND=wayland,x11

  ## Qt: semicolon-separated platform list. Quote the ';' so the shell does not
  ## treat it as a command separator.
  export QT_QPA_PLATFORM='wayland;xcb'
fi

if [ -z "$XDG_CONFIG_DIRS" ]; then
  XDG_CONFIG_DIRS="/etc:/etc/xdg:/usr/share"
  export XDG_CONFIG_DIRS
fi
if [ -z "$XDG_DATA_DIRS" ]; then
  XDG_DATA_DIRS="/usr/local/share/:/usr/share/"
  export XDG_DATA_DIRS
fi

if ! printf '%s\n' "$XDG_CONFIG_DIRS" | grep -- "/usr/share/desktop-config-dist" >/dev/null 2>/dev/null; then
  export XDG_CONFIG_DIRS="/usr/share/desktop-config-dist/:$XDG_CONFIG_DIRS"
fi

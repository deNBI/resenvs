#!/bin/sh
# xrdp X session start script — managed by Ansible
# Based on the Debian/Ubuntu xrdp default, patched for XFCE sessions
# (avoids immediate exit caused by inherited DBus / XDG runtime dir).

if test -r /etc/profile; then
        . /etc/profile
fi

if test -r ~/.profile; then
        . ~/.profile
fi

# Drop inherited bus/runtime dir so XFCE gets a fresh session
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

export XDG_CURRENT_DESKTOP=XFCE
export XDG_DATA_DIRS=/usr/share/xfce4:/usr/local/share:/usr/share

exec startxfce4

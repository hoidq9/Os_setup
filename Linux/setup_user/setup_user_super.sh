#!/bin/bash
source ../variables.sh

Main_remove_packages() {
    dnf remove vim-minimal vim-data vim-common vim-enhanced vi sassc glib2-devel ImageMagick dialog inkscape optipng vim-data dbus-x11 jq -y
    dnf autoremove -y
    dnf install PackageKit-command-not-found gnome-software fuse fuse-libs -y
}

check_and_run Main_remove_packages

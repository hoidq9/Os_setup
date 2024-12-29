#!/bin/bash
source ../variables.sh

System_clean() {
    dnf remove vim-minimal vim-data vim-common vim-enhanced vi sassc glib2-devel ImageMagick dialog inkscape optipng vim-data dbus-x11 opensc fprintd-pam gnome-tour -y
    dnf autoremove -y
    dnf install PackageKit-command-not-found gnome-software fuse fuse-libs -y
}

check_and_run System_clean "$REPO_DIR/../logs/System_clean.log" "$REPO_DIR/../logs/Result.log"

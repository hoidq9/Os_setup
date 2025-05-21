#!/bin/bash
source ../variables.sh

System_clean() {
    dnf remove vim-minimal vim-data vim-common vim-enhanced vi ImageMagick inkscape optipng vim-data opensc fprintd-pam gnome-tour default-editor -y # dbus-x11 glib2-devel dialog sassc
    dnf autoremove -y
    dnf install PackageKit-command-not-found gnome-software -y

    if [ "$os_id" != "fedora" ]; then
        dnf install fuse fuse-libs kernel-devel -y
    fi
}

check_and_run System_clean "$REPO_DIR/../logs/System_clean.log" "$REPO_DIR/../logs/Result.log"

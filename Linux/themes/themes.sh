#!/bin/bash
source ../variables.sh

dependencies() {
    cd "$REPO_DIR" || return
    mkdir -p themes_os
    cd themes_os
    mkdir -p WhiteSur-gtk-theme && curl -L $(curl -s https://api.github.com/repos/vinceliuice/WhiteSur-gtk-theme/releases/latest | grep "tarball" | cut -d '"' -f 4) | tar -xz -C WhiteSur-gtk-theme --strip-components=1
    cd WhiteSur-gtk-theme
    rm -rf src/assets/gnome-shell/backgrounds/*
    for target in background-default.png background-darken.png background-blank.png background-blur-darken.png background-blur.png; do
        cp $REPO_DIR/intel-processor.jpg src/assets/gnome-shell/backgrounds/$target
    done
    gawk -i inplace '!/Yaru/' src/main/gnome-shell/gnome-shell-theme.gresource.xml
    ./install.sh -n 'WoW' -o normal -c dark -a alt -t default -s standard -m -N mojave -HD --round --shell -b default -p 30 -h smaller -normal -sf
    ./tweaks.sh -o solid -c dark -t default -s standard -g -b default -p 30 -h smaller -sf
}
dependencies &>$REPO_DIR/../logs/main_themes.log

os_thems() {
    local os_name="$1"
    local theme_path="/usr/share/themes/WoW-Dark-alt"
    rm -rf /usr/share/themes/"${os_name}_themes"
    if [ -d "$theme_path" ]; then
        mv "$theme_path" "/usr/share/themes/${os_name}_themes"
    fi
    cd "/usr/share/themes/${os_name}_themes" || return
    rm -rf cinnamon plank gnome-shell
    cd ..
    rm -rf WoW*
    cd "$REPO_DIR" || return
    rm -rf themes_os
}

main_themes() {
    os_themes "$os_id"
}

check_and_run main_themes

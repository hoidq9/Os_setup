#!/bin/bash
source ../../variables.sh

prepare_directories_and_files() {
    local install_dir="$1"
    local app_dir="$2"
    local icon_dir="$3"

    mkdir -p "$install_dir" "$app_dir" "$icon_dir"

    cd "$install_dir" || return
    local filename
    filename=$(curl -OJ -w '%{filename_effective}' https://downloader.cursor.sh/linux/appImage/x64)
    mv -f "$filename" cursor
    chmod +x cursor

    cp -f "$REPO_DIR/cursor.svg" "$icon_dir"
    cp -f "$REPO_DIR/cursor.desktop" "$app_dir"

    sed -i "s|name_exec_h|$install_dir/cursor|g" "$app_dir/cursor.desktop"
    sed -i "s|name_icon_h|$icon_dir/cursor.svg|g" "$app_dir/cursor.desktop"
}

Apps_Cursor() {
    if [ "$EUID" -eq 0 ]; then
        prepare_directories_and_files "/usr/local/bin" "/usr/share/applications" "/usr/share/icons/cursor"
    else
        if [ ! -f "/usr/local/bin/cursor" ]; then
            prepare_directories_and_files "$HOME/Prj/Cursor" "$HOME/.local/share/applications" "$HOME/.local/share/icons/cursor"
        fi
    fi
}

# check_and_run Apps_Cursor "$REPO_DIR/../../logs/Apps_Cursor.log" "$REPO_DIR/../../logs/Result.log"

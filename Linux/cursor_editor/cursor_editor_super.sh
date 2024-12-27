#!/bin/bash
source ../variables.sh

main_cursor_editor() {
    cd "$REPO_DIR" || return
    filename=$(curl -OJ -w '%{filename_effective}' https://downloader.cursor.sh/linux/appImage/x64)
    mv $filename /usr/local/bin/cursor
    chmod +x /usr/local/bin/cursor
    mkdir -p /usr/share/icons/cursor_ai
    cp cursor_ai.svg /usr/share/icons/cursor_ai
    cp cursor.desktop /usr/share/applications
}

check_and_run main_cursor_editor

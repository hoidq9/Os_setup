#!/bin/bash
source $(pwd)/variables.sh

tasks=(
    'wifi_packages'
    'system'
    'bootloader'
    'themes'
    'icons'
    'cursors'
    'fonts'
    'gdms'
    'cursor_editor'
    'extensions_gnome'
    'setup_user'
)

for task in "${tasks[@]}"; do
    cd $REPO_DIR/$task
    sh "$task"_super.sh
done

chmod -R 777 $REPO_DIR/logs

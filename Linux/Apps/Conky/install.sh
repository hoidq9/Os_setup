#!/bin/bash
source ../../variables.sh

Apps_Conky() {
    cd $REPO_DIR
    if [ command -v conky ] &>/dev/null; then

        if [ ! -d /home/$user_current/.config/autostart ]; then
            mkdir -p /home/$user_current/.config/autostart
        fi
        if rpm -q conky >/dev/null 2>&1; then
            cp $REPO_DIR/conky.desktop /home/$user_current/.config/autostart
        fi

        if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
            cp conky_wayland.conf ~/.config/conky/conky.conf
        elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
            cp conky_x11.conf ~/.config/conky/conky.conf
        fi
    fi
}
check_and_run Apps_Conky "$REPO_DIR/../../logs/Apps_Conky.log" "$REPO_DIR/../../logs/Result.log"

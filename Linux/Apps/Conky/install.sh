#!/bin/bash
source ../../variables.sh

Apps_Conky() {
    cd $REPO_DIR
    if [ "$os_id" == "fedora" ]; then
        cd fedora
        if rpm -q conky; then

            if [ ! -d /home/$user_current/.config/autostart ]; then
                mkdir -p /home/$user_current/.config/autostart
            fi

            cp conky.desktop /home/$user_current/.config/autostart
            mkdir -p /home/$user_current/.config/conky

            if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
                cp conky_wayland.conf ~/.config/conky/
                mv ~/.config/conky/conky_wayland.conf ~/.config/conky/conky.conf
            elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
                cp conky_x11.conf ~/.config/conky/
                mv ~/.config/conky/conky_x11.conf ~/.config/conky/conky.conf
            fi
        fi
    else
        echo "The script is not supported on this OS."
    fi
}
check_and_run Apps_Conky "$REPO_DIR/../../logs/Apps_Conky.log" "$REPO_DIR/../../logs/Result.log"

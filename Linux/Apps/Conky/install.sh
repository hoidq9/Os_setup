#!/bin/bash
source ../../variables.sh

Apps_Conky() {
    local environment_display
    cd $REPO_DIR

    if rpm -q conky; then

        if [ ! -d /home/$user_current/.config/autostart ]; then
            mkdir -p /home/$user_current/.config/autostart
        fi

        cp conky.desktop /home/$user_current/.config/autostart
        mkdir -p /home/$user_current/.config/conky
        cd $os_id

        if [ "$os_id" == "fedora" ]; then
            # if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
            #     cp conky_wayland.conf ~/.config/conky/
            #     mv ~/.config/conky/conky_wayland.conf ~/.config/conky/conky.conf
            # elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
            #     cp conky_x11.conf ~/.config/conky/
            #     mv ~/.config/conky/conky_x11.conf ~/.config/conky/conky.conf
            # fi

            if [ ! -f $HOME/.config/conky/conky.conf ]; then
                cp -f conky.conf /home/$user_current/.config/conky/
            fi

        elif [ "$os_id" == "almalinux" ]; then
            if [ ! -f $HOME/.config/conky/conky.conf ]; then
                cp -f conky.conf /home/$user_current/.config/conky/
            fi
        fi

    elif [ "$os_id" == "rhel" ]; then

        if [ ! -d /home/$user_current/.config/autostart ]; then
            mkdir -p /home/$user_current/.config/autostart
        fi

        cd $os_id

        curl -s https://api.github.com/repos/brndnmtthws/conky/releases/latest |
            grep "browser_download_url.*\\.AppImage\"" |
            head -n1 |
            cut -d '"' -f4 |
            xargs curl -L -o conky.AppImage

        mkdir -p /home/$user_current/Conky
        mv conky.AppImage $HOME/Conky
        chmod +x $HOME/Conky/conky.AppImage
        cp conky_rhel.desktop conky.desktop
        sed -i "s/name_user_h/$user_current/g" conky.desktop
        if [ ! -d $HOME/.local/share/applications ]; then
            mkdir -p $HOME/.local/share/applications
        fi
        cp conky.desktop $HOME/.local/share/applications
        cp conky.desktop /home/$user_current/.config/autostart
        rm -rf conky.desktop

        if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
            environment_display="wayland"
        elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
            environment_display="x11"
        fi

        mkdir -p /home/$user_current/.config/conky
        cp -f conky_$environment_display.conf /home/$user_current/.config/conky/conky.conf

        # mkdir -p ~/.config/systemd/user
        # cp -r conky_$environment_display.service conky.service
        # sed -i "s/name_user_h/$user_current/g" conky.service
        # mv conky.service ~/.config/systemd/user
        # systemctl --user enable conky.service
        # systemctl --user start conky.service
        # loginctl enable-linger $user_current

    fi
}

check_and_run Apps_Conky "$REPO_DIR/../../logs/Apps_Conky.log" "$REPO_DIR/../../logs/Result.log"

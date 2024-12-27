#!/bin/bash
source ../variables.sh

main_user_config() {
    yubico() {
        rm -rf $HOME/Prj/Yubico
        cd "$HOME/Prj" || return
        wget $(curl -s https://api.github.com/repos/Yubico/yubioath-flutter/releases/latest | grep "browser_download_url" | grep "linux" | grep "tar.gz" | cut -d '"' -f 4)
        yubico_compress=$(ls -d *.tar.gz)
        dir_name=$(basename $yubico_compress .tar.gz)
        mkdir -p Yubico/$dir_name
        tar -xzvf $yubico_compress -C Yubico/$dir_name --strip-components=1
        cd "$HOME/Prj/Yubico/$dir_name" || return
        ./desktop_integration.sh -i
        cd "$HOME/Prj" || return
        rm -rf *.tar.gz *.tar.gz.sig
    }

    ohmyzsh_user() {
        if rpm -q zsh >/dev/null 2>&1; then
            rm -rf $HOME/.zshrc.pre-oh-my-zsh*
            if [ ! -d "$HOME/.oh-my-zsh" ]; then
                mkdir -p $REPO_DIR/ohmyzsh
                cd $REPO_DIR/ohmyzsh
                wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
                sh install.sh --unattended
                declare -a gitarray
                gitarray=(
                    'zsh-users/zsh-syntax-highlighting.git '$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting''
                    'zsh-users/zsh-autosuggestions '$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions''
                    'spaceship-prompt/spaceship-prompt.git '$HOME/.oh-my-zsh/custom/themes/spaceship-prompt''
                    'TamCore/autoupdate-oh-my-zsh-plugins '$HOME/.oh-my-zsh/custom/plugins/autoupdate''
                )
                for i in "${gitarray[@]}"; do
                    echo $(git clone https://github.com/$i)
                done
                ln -s $HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme $HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme
                rm -rf $HOME/.oh-my-zsh/themes
            else
                cd $HOME/.oh-my-zsh
                git pull
            fi
            cd $REPO_DIR/
            rm -rf ohmyzsh

            config_file="zshrc_config/_${os_id}_user.zshrc"
            if [ -f "$config_file" ]; then
                cp -f "$config_file" "$HOME/.zshrc"
            fi
            cp -f spaceshiprc_config/_user_spaceshiprc.zsh $HOME/.spaceshiprc.zsh
        fi
    }

    terminal() {
        id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ visible-name "'$user_current'"
        gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ cursor-shape "'ibeam'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy "'<Ctrl>C'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab "'<Ctrl>T'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window "'<Ctrl>N'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ save-contents "'<Ctrl>S'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab "'<Ctrl>W'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window "'<Ctrl>Q'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy-html "'<Ctrl>X'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste "'<Ctrl>V'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ select-all "'<Ctrl>A'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ preferences "'<Ctrl>P'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find "'<Ctrl>F'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-next "'<Ctrl>G'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-previous "'<Ctrl>H'"
        gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-clear "'<Ctrl>J'"
        cd $REPO_DIR/
        git clone https://github.com/dracula/gnome-terminal
        cd gnome-terminal
        ./install.sh -s Dracula -p $user_current --skip-dircolors
        cd $REPO_DIR/
        rm -rf gnome-terminal
    }

    accessibility() {
        if [ -d "/usr/share/themes/"$os_id"_themes" ]; then
            gsettings set org.gnome.desktop.interface gtk-theme "$os_id"_themes
        fi
        if [ -d "/usr/share/icons/"$os_id"_icons" ]; then
            gsettings set org.gnome.desktop.interface icon-theme "$os_id"_icons
        fi
        if [ -d "/usr/share/icons/"$os_id"_cursors" ]; then
            gsettings set org.gnome.desktop.interface cursor-theme "$os_id"_cursors
        fi
        mkdir -p $HOME/.local/share/backgrounds
        cp $REPO_DIR/backgrounds/Lenovo_Legion_Wallpaper.png $HOME/.local/share/backgrounds
        mkdir -p $HOME/.icons
        cd $REPO_DIR/icons_extensions
        cp -r * $HOME/.icons
        gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
        gsettings set org.gnome.desktop.interface clock-show-date true
        gsettings set org.gnome.desktop.interface show-battery-percentage true
        gsettings set org.gnome.desktop.interface clock-show-seconds true
        gsettings set org.gnome.desktop.interface clock-show-weekday true
        gsettings set org.gnome.desktop.interface enable-hot-corners false
        gsettings set org.gnome.desktop.interface locate-pointer true
        gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
        gsettings set org.gnome.desktop.session idle-delay 0
        gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
        gsettings set org.gnome.desktop.input-sources show-all-sources true
        gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2595
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0
        gsettings set org.gnome.desktop.input-sources sources "[('ibus', 'm17n:vi:telex'), ('xkb', 'us')]"
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
        gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'
        gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
        gsettings set org.gnome.desktop.screensaver lock-delay 0
        gsettings set org.gnome.desktop.screensaver lock-enabled true
        gsettings set org.gnome.desktop.datetime automatic-timezone true
        gsettings set org.gnome.desktop.calendar show-weekdate true
        gsettings set org.gnome.desktop.interface clock-format '24h'
        gsettings set org.gnome.system.location enabled true
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
        gsettings set org.gnome.nautilus.window-state initial-size '(2082, 1256)'
        gsettings set org.gnome.nautilus.window-state initial-size-file-chooser '(890, 550)'
        gsettings set org.gnome.nautilus.preferences always-use-location-entry false
        gsettings set org.gnome.nautilus.preferences date-time-format 'detailed'
        gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
        gsettings set org.gnome.nautilus.preferences migrated-gtk-settings true
        gsettings set org.gnome.nautilus.preferences search-filter-time-type 'last_modified'
        gsettings set org.gnome.nautilus.preferences show-create-link true
        gsettings set org.gnome.nautilus.preferences show-delete-permanently true
        gsettings set org.gnome.nautilus.list-view default-column-order "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']"
        gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']"
        gsettings set org.gnome.nautilus.list-view use-tree-view false
        gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$user_current/.local/share/backgrounds/Lenovo_Legion_Wallpaper.png"
        gsettings set org.gnome.desktop.background picture-uri "file:///home/$user_current/.local/share/backgrounds/Lenovo_Legion_Wallpaper.png"
        cd $REPO_DIR/
    }

    keybinding() {
        KEY0_PATH="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
        KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
            "['$KEY_PATH/custom0/']"
        gsettings set $KEY0_PATH:$KEY_PATH/custom0/ name "GNOME Terminal"
        gsettings set $KEY0_PATH:$KEY_PATH/custom0/ command "gnome-terminal"
        gsettings set $KEY0_PATH:$KEY_PATH/custom0/ binding "<Primary><Alt>T"
    }

    update_firefox_userChrome() {
        local file_path="$HOME/.mozilla/firefox/firefox-themes/userChrome.css"
        local new_code='#sidebar-header {
        display: none;
    }

    #sidebar-box {
        min-width: 100px !important;
    }

    #TabsToolbar {
        visibility: collapse !important;
    }'

        if [ -f "$file_path" ]; then
            if ! grep -qF -- "$new_code" "$file_path"; then
                echo "$new_code" >>"$file_path"
                echo "Đã thêm đoạn mã vào tệp userChrome.css."
            else
                echo "Đoạn mã đã tồn tại trong tệp userChrome.css."
            fi
        else
            echo "Tệp userChrome.css không tồn tại."
        fi
    }

    bookmark_nautilus() {
        bookmarks_file="$HOME/.config/gtk-3.0/bookmarks"
        folders=(
            "$HOME/Prj"
            "/Os_H/Windows_H"
            "$HOME/Prj/Yubico"
        )
        check_and_add_bookmark() {
            folder_path="$1"
            if ! grep -q "^file:/// /$" "$bookmarks_file" 2>/dev/null; then
                echo "file:/// /" >>"$bookmarks_file"
            else
                echo "Đã tồn tại / trong $bookmarks_file."
            fi
            if [ -d "$folder_path" ] && ! grep -q "file://$folder_path" "$bookmarks_file"; then
                echo "file://$folder_path" >>"$bookmarks_file"
                echo "Đã thêm $folder_path vào bookmark."
            else
                echo "$folder_path đã có hoặc thư mục không tồn tại."
            fi
        }

        for folder in "${folders[@]}"; do
            check_and_add_bookmark "$folder"
        done
    }

    gnome_extensions_normal() {
        # wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh

        for zip_extensions in $REPO_DIR/../extensions_gnome/gnome_extensions_list/*.zip*; do
            gnome-extensions install "$zip_extensions" -f
        done

        for extension_uuid in $HOME/.local/share/gnome-shell/extensions/*; do
            gnome-extensions enable "$(basename "$extension_uuid")"
        done

        if [ "$os_id" == "fedora"]; then
            if [ -d "$HOME/.local/share/gnome-shell/extensions/system-monitor-next@paradoxxx.zero.gmail.com" ]; then
                sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._centerBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor-next@paradoxxx.zero.gmail.com/extension.js
            fi

            cd $REPO_DIR/../extensions_gnome
            if [ -d "$HOME/.local/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com" ]; then
                rm -rf $HOME/.config/burn-my-windows/profiles
                mkdir -p $HOME/.config/burn-my-windows/profiles
                cp -r burn-my-windows-profile.conf $HOME/.config/burn-my-windows/profiles
            fi

            if dconf list /org/gnome/shell/extensions/ &>/dev/null; then
                cp -r _fedora_extensions.conf all_extensions
                sed -i "s/name_user_h/$user_current/g" all_extensions
                dconf load /org/gnome/shell/extensions/ <all_extensions
                rm -rf all_extensions
            fi

            rm -rf gnome_extensions_list

        elif [ "$os_id" == "rhel"]; then
            sed -i "s/Main.panel.addToStatusArea ('cpufreq-indicator', monitor);/Main.panel.addToStatusArea ('cpufreq-indicator', monitor, 0, 'center');/g" $HOME/.local/share/gnome-shell/extensions/cpufreq@konkor/extension.js
            sed -i "s/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 0, 'right')/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 1, 'right')/g" $HOME/.local/share/gnome-shell/extensions/extension-list@tu.berry/extension.js
            sed -i "s/panel.addToStatusArea('extensions-sync', this.button);/panel.addToStatusArea('extensions-sync', this.button, '2', 'right');/g" $HOME/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/extension.js
            sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._leftBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/extension.js
            sed -i "s/var UPDATE_INTERVAL_CPU = 2000;/var UPDATE_INTERVAL_CPU = 100;/g" $HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/lib/config.js

        fi

        dconf write /org/gnome/shell/disable-user-extensions false
    }

    tasks=(
        "yubico"
        "ohmyzsh_user"
        "terminal"
        "accessibility"
        "gnome_extensions_normal"
        "keybinding"
        # "update_firefox_userChrome"
        "bookmark_nautilus"
    )

    for task in "${tasks[@]}"; do
        check_and_run "$task"
    done

}

check_and_run main_user_config

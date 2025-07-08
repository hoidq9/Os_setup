#!/bin/bash
source ../variables.sh

User_setup() {

    Ohmyzsh_User() {
        if rpm -q zsh >/dev/null 2>&1 && command -v git >/dev/null 2>&1; then
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

            config_file="zshrc_cfg/_${os_id}_user.zshrc"
            if [ -f "$config_file" ]; then
                cp -f "$config_file" "$HOME/.zshrc"
            fi
            cp -f spaceshiprc_cfg/_user_spaceshiprc.zsh $HOME/.spaceshiprc.zsh
        fi
    }

    terminal() {
        # id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
        # gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ use-system-font false

        id=$(gsettings get org.gnome.Ptyxis default-profile-uuid | tr -d "'")
        gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$id/ label "'$user_current'"
        gsettings set org.gnome.Ptyxis.Profile:/org/gnome/Ptyxis/Profiles/$id/ palette "'dracula'"

        gsettings set org.gnome.Ptyxis use-system-font false
        gsettings set org.gnome.Ptyxis font-name 'FiraCode Nerd Font Mono Semi-Bold 11'

        # if [ "$os_id" == "almalinux" ] || [ "$os_id" == "rhel" ]; then
        #     gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ font 'Red Hat Mono Light, Medium 12'
        # elif [ "$os_id" == "fedora" ]; then
        #     gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ font 'FiraCode Nerd Font Mono Bold Italic 11'
        # fi

        # gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ visible-name "'$user_current'"
        # gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/ cursor-shape "'ibeam'"

        gsettings set org.gnome.Ptyxis cursor-shape 'ibeam'
        gsettings set org.gnome.Ptyxis interface-style 'dark'
        gsettings set org.gnome.Ptyxis.Shortcuts copy-clipboard '<ctrl>c'
        gsettings set org.gnome.Ptyxis.Shortcuts paste-clipboard '<ctrl>v'
        gsettings set org.gnome.Ptyxis.Shortcuts new-tab '<ctrl>t'
        gsettings set org.gnome.Ptyxis.Shortcuts new-window '<ctrl>n'
        gsettings set org.gnome.Ptyxis.Shortcuts close-tab '<ctrl>w'
        gsettings set org.gnome.Ptyxis.Shortcuts select-all '<ctrl>a'
        gsettings set org.gnome.Ptyxis.Shortcuts search '<ctrl>f'
        gsettings set org.gnome.Ptyxis.Shortcuts tab-overview '<ctrl>o'

        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy "'<Ctrl>C'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-tab "'<Ctrl>T'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ new-window "'<Ctrl>N'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ save-contents "'<Ctrl>S'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-tab "'<Ctrl>W'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ close-window "'<Ctrl>Q'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ copy-html "'<Ctrl>X'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ paste "'<Ctrl>V'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ select-all "'<Ctrl>A'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ preferences "'<Ctrl>P'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find "'<Ctrl>F'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-next "'<Ctrl>G'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-previous "'<Ctrl>H'"
        # gsettings set org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ find-clear "'<Ctrl>J'"
        # if command -v git >/dev/null 2>&1; then
        #     if command -v gnome-terminal >/dev/null 2>&1; then
        #         cd $REPO_DIR/
        #         git clone https://github.com/dracula/gnome-terminal
        #         cd gnome-terminal
        #         ./install.sh -s Dracula -p $user_current --skip-dircolors
        #         cd $REPO_DIR/
        #         rm -rf gnome-terminal
        #     fi
        # fi
    }

    accessibility() {
        if [ -d "/usr/share/themes/"$os_id"_themes" ] || [ -d "$HOME/.local/share/themes/"$os_id"_themes" ]; then
            gsettings set org.gnome.desktop.interface gtk-theme "$os_id"_themes
        fi
        if [ -d "/usr/share/icons/"$os_id"_icons" ] || [ -d "$HOME/.local/share/icons/"$os_id"_icons" ]; then
            gsettings set org.gnome.desktop.interface icon-theme "$os_id"_icons
        fi
        if [ -d "/usr/share/icons/"$os_id"_cursors" ] || [ -d "$HOME/.local/share/icons/"$os_id"_cursors" ]; then
            gsettings set org.gnome.desktop.interface cursor-theme "$os_id"_cursors
        fi

        mkdir -p $HOME/.local/share/backgrounds
        cp $REPO_DIR/backgrounds/Lenovo_Legion_Wallpaper.png $HOME/.local/share/backgrounds
        gsettings set org.gnome.desktop.background picture-uri-dark "file:///home/$user_current/.local/share/backgrounds/Lenovo_Legion_Wallpaper.png"
        gsettings set org.gnome.desktop.background picture-uri "file:///home/$user_current/.local/share/backgrounds/Lenovo_Legion_Wallpaper.png"

        gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
        gsettings set org.gnome.desktop.interface clock-show-date true
        gsettings set org.gnome.desktop.interface show-battery-percentage true
        gsettings set org.gnome.desktop.interface clock-show-seconds true
        gsettings set org.gnome.desktop.interface clock-show-weekday true
        gsettings set org.gnome.desktop.interface enable-hot-corners false
        gsettings set org.gnome.desktop.interface locate-pointer false
        gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
        gsettings set org.gnome.desktop.session idle-delay 0
        gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
        gsettings set org.gnome.desktop.input-sources show-all-sources true
        gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
        gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
        gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 2595
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
        gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('ibus', 'm17n:vi:telex')]"
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
        # gsettings set org.gnome.nautilus.window-state initial-size '(2082, 1256)'
        # gsettings set org.gnome.nautilus.window-state initial-size-file-chooser '(890, 550)'
        gsettings set org.gnome.nautilus.preferences always-use-location-entry false
        gsettings set org.gnome.nautilus.preferences date-time-format 'detailed'
        gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'
        gsettings set org.gnome.nautilus.preferences migrated-gtk-settings true
        gsettings set org.gnome.nautilus.preferences search-filter-time-type 'last_modified'
        gsettings set org.gnome.nautilus.preferences show-create-link true
        gsettings set org.gnome.nautilus.preferences show-delete-permanently true
        gsettings set org.gnome.nautilus.list-view default-column-order "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']"
        gsettings set org.gnome.nautilus.list-view default-visible-columns "['name', 'size', 'type', 'owner', 'group', 'permissions', 'date_modified', 'date_accessed', 'date_created', 'recency', 'detailed_type']"
        gsettings set org.gnome.nautilus.list-view use-tree-view true
        gsettings set org.gnome.desktop.privacy remove-old-temp-files true
        gsettings set org.gnome.desktop.privacy remove-old-trash-files true
        gsettings set org.gnome.desktop.privacy report-technical-problems true
        gsettings set org.gnome.nautilus.preferences show-hidden-files true
        gsettings set org.gtk.Settings.FileChooser show-hidden true
        gsettings set org.gtk.gtk4.Settings.FileChooser show-hidden true
        if [ "$os_id" == "rhel" ]; then
            gsettings set org.gnome.desktop.interface document-font-name 'Adwaita Sans 11'  # Red Hat Text Medium 11 @wght=500
            gsettings set org.gnome.desktop.interface font-name 'Adwaita Sans 11'           # Red Hat Text Semi-Bold 11 @wght=600
            gsettings set org.gnome.desktop.interface monospace-font-name 'Adwaita Mono 11' # Red Hat Mono Semi-Bold 11 @wght=600
            gsettings set org.gnome.shell favorite-apps "['org.gnome.Ptyxis.desktop', 'code.desktop', 'org.gnome.Settings.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Software.desktop', 'microsoft-edge.desktop', 'google-chrome.desktop', 'org.gnome.SystemMonitor.desktop', 'org.gnome.tweaks.desktop', 'nvidia-settings.desktop', 'org.gnome.seahorse.Application.desktop', 'com.yubico.yubioath.desktop', 'org.gnome.Extensions.desktop', 'yandex-browser.desktop']"
            # "['org.gnome.Terminal.desktop', 'org.cockpit_project.CockpitClient.desktop', 'gnome-control-center.desktop', 'conky.desktop', 'gnome-system-monitor.desktop', 'virt-manager.desktop']"
        elif [ "$os_id" == "fedora" ]; then
            gsettings set org.gnome.shell favorite-apps "['org.gnome.Ptyxis.desktop', 'org.gnome.Settings.desktop', 'code.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Software.desktop', 'org.gnome.Nautilus.desktop', 'microsoft-edge.desktop', 'google-chrome.desktop', 'com.yubico.yubioath.desktop', 'org.gnome.SystemMonitor.desktop', 'conky.desktop', 'virt-manager.desktop']" # 'org.gnome.Terminal.desktop' 'com.yubico.authenticator.desktop'
        elif [ "$os_id" == "almalinux" ]; then
            gsettings set org.gnome.shell favorite-apps "['org.gnome.Terminal.desktop', 'org.cockpit_project.CockpitClient.desktop', 'gnome-control-center.desktop', 'code.desktop', 'cursor.desktop', 'org.gnome.Software.desktop', 'org.gnome.DiskUtility.desktop', 'org.gnome.Nautilus.desktop', 'microsoft-edge.desktop', 'google-chrome.desktop', 'com.yubico.authenticator.desktop', 'conky.desktop', 'gnome-system-monitor.desktop', 'virt-manager.desktop']"
        fi
        cd $REPO_DIR/
    }

    keybinding() {
        KEY0_PATH="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
        KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
        gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
            "['$KEY_PATH/custom0/']"
        gsettings set $KEY0_PATH:$KEY_PATH/custom0/ name "Terminal"
        gsettings set $KEY0_PATH:$KEY_PATH/custom0/ command "ptyxis"
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
            "$HOME/Conky"
            "/NVIDIA"
        )
        check_and_add_bookmark() {
            folder_path="$1"

            if ! grep -q "^file:/// /$" "$bookmarks_file" 2>/dev/null; then
                echo "file:/// /" >>"$bookmarks_file"
            fi

            if [ -d "$folder_path" ] && ! grep -q "file://$folder_path" "$bookmarks_file"; then
                echo "file://$folder_path" >>"$bookmarks_file"
            fi
        }

        for folder in "${folders[@]}"; do
            check_and_add_bookmark "$folder"
        done

        if [ ! -d "/Os_H/Windows_H" ] && grep -q "file:///Os_H/Windows_H" "$bookmarks_file"; then
            sed -i "/file:\/\/\/Os_H\/Windows_H/d" "$bookmarks_file"
        fi
    }

    User_gnome_extensions() {
        # wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh

        if [ "$os_id" == "fedora" ]; then
            extensions=('3628' '6272' '6682' '4679' '1160' '3843' '3010' '3733')
        elif [ "$os_id" == "rhel" ]; then
            #     extensions=('1486' '3088' '3628' '4679' '1082' '3843' '120' '3733' '5219' '1460' '4670' '1160' '6272')
            extensions=('3628' '6682' '1500' '1160' '3843' '3010' '3733' '5928' '6580' '1319' '2224')
        elif [ "$os_id" == "almalinux" ]; then
            extensions=('3628' '3843' '3010' '3733' '1160') # '3628' '1486' '3843' '4405' '3010' '4679' '3733' '4670' '1082'
        fi

        for i in "${extensions[@]}"; do
            sh $REPO_DIR/extensions_gnome/install-gnome-extensions.sh -e -o -u "$i"
        done

        if [ "$os_id" == "fedora" ]; then

            mkdir -p $HOME/.local/share/icons/
            cd $REPO_DIR/extensions_gnome/icons/fedora
            cp -r * $HOME/.local/share/icons/

            if [ -d "$HOME/.local/share/gnome-shell/extensions/system-monitor-next@paradoxxx.zero.gmail.com" ]; then
                sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._centerBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor-next@paradoxxx.zero.gmail.com/extension.js
            fi

            cd $REPO_DIR/extensions_gnome/config
            if [ -d "$HOME/.local/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com" ]; then
                mkdir -p $HOME/.config/burn-my-windows/profiles
                cp -r burn-my-windows-profile.conf $HOME/.config/burn-my-windows/profiles
            fi

            if dconf list /org/gnome/shell/extensions/ &>/dev/null; then
                cp -r _fedora_extensions.conf all_extensions
                sed -i "s/name_user_h/$user_current/g" all_extensions
                dconf load /org/gnome/shell/extensions/ <all_extensions
                rm -rf all_extensions
            fi

            if [ -d "$HOME/.local/share/gnome-shell/extensions/AddCustomTextToWorkSpaceIndicators@pratap.fastmail.fm" ]; then
                sed -i "s|.icons|.local/share/icons|g" $HOME/.local/share/gnome-shell/extensions/AddCustomTextToWorkSpaceIndicators@pratap.fastmail.fm/prefs.js
            fi

        elif [ "$os_id" == "rhel" ]; then

            mkdir -p $HOME/.local/share/icons/
            cd $REPO_DIR/extensions_gnome/icons/rhel
            cp -r brand-logo-symbolic.svg RhelH.svg $HOME/.local/share/icons/

            cd $REPO_DIR/extensions_gnome/config

            # if [ -d "$HOME/.local/share/gnome-shell/extensions/burn-my-windows@schneegans.github.com" ]; then
            #     mkdir -p $HOME/.config/burn-my-windows/profiles
            #     cp -r burn-my-windows-profile.conf $HOME/.config/burn-my-windows/profiles
            # fi

            if dconf list /org/gnome/shell/extensions/ &>/dev/null; then
                cp -r _rhel_extensions.conf all_extensions
                sed -i "s/name_user_h/$user_current/g" all_extensions
                dconf load /org/gnome/shell/extensions/ <all_extensions
                rm -rf all_extensions
            fi
        #     sed -i "s/Main.panel.addToStatusArea ('cpufreq-indicator', monitor);/Main.panel.addToStatusArea ('cpufreq-indicator', monitor, 0, 'center');/g" $HOME/.local/share/gnome-shell/extensions/cpufreq@konkor/extension.js
        #     sed -i "s/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 0, 'right')/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 1, 'right')/g" $HOME/.local/share/gnome-shell/extensions/extension-list@tu.berry/extension.js
        #     sed -i "s/panel.addToStatusArea('extensions-sync', this.button);/panel.addToStatusArea('extensions-sync', this.button, '2', 'right');/g" $HOME/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/extension.js
        #     sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._leftBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/extension.js
        #     sed -i "s/var UPDATE_INTERVAL_CPU = 2000;/var UPDATE_INTERVAL_CPU = 100;/g" $HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/lib/config.js

        elif [ "$os_id" == "almalinux" ]; then
            # sed -i "s/Main.panel.addToStatusArea ('cpufreq-indicator', monitor);/Main.panel.addToStatusArea ('cpufreq-indicator', monitor, 1, 'left');/g" $HOME/.local/share/gnome-shell/extensions/cpufreq@konkor/extension.js
            # sed -i "s/panel.addToStatusArea('extensions-sync', this.button);/panel.addToStatusArea('extensions-sync', this.button, '2', 'right');/g" $HOME/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/extension.js
            # sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._leftBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor-next@paradoxxx.zero.gmail.com/extension.js

            mkdir -p $HOME/.local/share/icons/
            cd $REPO_DIR/extensions_gnome/icons
            cp -r brand-logo-symbolic.svg $HOME/.local/share/icons/

            if dconf list /org/gnome/shell/extensions/ &>/dev/null; then
                cp -r _alma_extensions.conf all_extensions
                sed -i "s/name_user_h/$user_current/g" all_extensions
                dconf load /org/gnome/shell/extensions/ <all_extensions
                rm -rf all_extensions
            fi

        fi

        dconf write /org/gnome/shell/disable-user-extensions false

    }

    autostart_edge() {
        if [ "$os_id" == "rhel" ] && systemd-detect-virt | grep -q "none"; then
            if [ -d "$HOME/.config/autostart" ] && rpm -q microsoft-edge-stable >/dev/null 2>&1; then
                cd $REPO_DIR/
                cp microsoft-edge.desktop $HOME/.config/autostart/
            fi
        fi
    }

    autostart_vscode() {
        if [ "$os_id" == "rhel" ] && systemd-detect-virt | grep -q "none"; then
            if [ -d "$HOME/.config/autostart" ] && rpm -q code >/dev/null 2>&1; then
                cd $REPO_DIR/
                cp code.desktop $HOME/.config/autostart/
            fi
        fi
    }

    tasks=(
        "terminal"
        "accessibility"
        "keybinding"
        # "update_firefox_userChrome"
        "bookmark_nautilus"
        # "autostart_edge"
        "autostart_vscode"
    )

    for task in "${tasks[@]}"; do
        "$task"
    done

    check_and_run Ohmyzsh_User "$REPO_DIR/../logs/Ohmyzsh_User.log" "$REPO_DIR/../logs/Result.log"
    check_and_run User_gnome_extensions "$REPO_DIR/../logs/User_gnome_extensions.log" "$REPO_DIR/../logs/Result.log"

}

check_and_run User_setup "$REPO_DIR/../logs/User_setup.log" "$REPO_DIR/../logs/Result.log"

#!/bin/bash

# if [ -f /home/$user_current/.config/monitors.xml ]; then
#     cp /home/$user_current/.config/monitors.xml ~gdm/.config/monitors.xml
#     chown gdm:gdm ~gdm/.config/monitors.xml
# fi

# if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
#     sudo -u gdm dbus-launch gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
# elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
#     sudo -u gdm dbus-launch gsettings set org.gnome.mutter experimental-features "['x11-randr-fractional-scaling']"
# fi
source ../../variables.sh

System_gdm() {
    settings=(
        # "org.gnome.desktop.interface text-scaling-factor 1.25"
        # "org.gnome.desktop.interface gtk-theme '"$os_id"_themes'"
        "org.gnome.desktop.interface icon-theme '"$os_id"_icons'"
        "org.gnome.desktop.interface cursor-theme '"$os_id"_cursors'"
        "org.gnome.desktop.interface clock-show-date true"
        "org.gnome.desktop.interface show-battery-percentage true"
        "org.gnome.desktop.interface clock-show-seconds true"
        "org.gnome.desktop.interface clock-show-weekday true"
        "org.gnome.settings-daemon.plugins.power power-button-action 'action'"
        "org.gnome.desktop.peripherals.touchpad tap-to-click true"
        "org.gnome.login-screen disable-user-list true"
        "org.gnome.settings-daemon.plugins.color night-light-schedule-automatic false"
        "org.gnome.settings-daemon.plugins.color night-light-enabled true"
        "org.gnome.settings-daemon.plugins.color night-light-temperature 2595"
        "org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0"
        "org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0"
        "org.gnome.login-screen banner-message-enable true"
        "org.gnome.login-screen banner-message-text 'LeaderH'"
        "org.gnome.desktop.sound allow-volume-above-100-percent true"
        "org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'"
        "org.gnome.settings-daemon.plugins.power sleep-inactive-battery-type 'nothing'"
        "org.gnome.settings-daemon.plugins.power idle-dim false"
        "org.gnome.desktop.screensaver lock-delay 0"
        "org.gnome.desktop.screensaver lock-enabled true"
        "org.gnome.desktop.datetime automatic-timezone true"
        "org.gnome.desktop.calendar show-weekdate true"
        "org.gnome.desktop.interface clock-format '24h'"
        "org.gnome.system.location enabled true"
    )
    for setting in "${settings[@]}"; do
        sudo -u gdm dbus-launch gsettings set $setting
    done

    if [ "$os_id" == "fedora" ]; then
        sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
        # cp $REPO_DIR/custom.conf /etc/gdm
    fi

    sudo systemctl enable gdm
}

check_and_run System_gdm "$REPO_DIR/../../logs/System_gdm.log" "$REPO_DIR/../../logs/Result.log"

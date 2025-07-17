#!/bin/bash
source ../../variables.sh

if [ $os_id == "fedora" ]; then
    dnf install keepassxc -y
elif [ $os_id == "rhel" ]; then
    dnf install gnome-software -y
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.keepassxc.KeePassXC
fi

mkdir -p /home/$user_current/.config/autostart
cp $REPO_DIR/start.desktop $REPO_DIR/org.keepassxc.KeePassXC.desktop /home/$user_current/.config/autostart/
systemctl --user mask gnome-keyring-daemon.service gnome-keyring-daemon.socket
mkdir -p /home/$user_current/.local/share/dbus-1/services
cp $REPO_DIR/org.freedesktop.secrets.service /home/$user_current/.local/share/dbus-1/services/

if [ $os_id == "fedora" ]; then
    sed -i 's|^Exec=.*|Exec=/usr/bin/keepassxc|g' /home/$user_current/.local/share/dbus-1/services/org.freedesktop.secrets.service
    rm -rf /home/$user_current/.config/autostart/org.keepassxc.KeePassXC.desktop
    cp $REPO_DIR/keepassxc.desktop /home/$user_current/.config/autostart/
fi

#!/bin/bash
source variables.sh

# GDM Config
gdm_config() {
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface text-scaling-factor 1.25
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface gtk-theme 'redhat-alt'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface icon-theme 'rhel'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface cursor-theme 'WhiteSur-cursors'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface clock-show-date true
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface show-battery-percentage true
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface clock-show-seconds true
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.interface clock-show-weekday true
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'action'
	sudo -u gdm dbus-launch gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click 'true'
	sudo -u gdm dbus-launch gsettings set org.gnome.login-screen disable-user-list true
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-temperature 3168
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-from 0.0
	sudo -u gdm dbus-launch gsettings set org.gnome.settings-daemon.plugins.color night-light-schedule-to 0.0
	sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-enable true
	sudo -u gdm dbus-launch gsettings set org.gnome.login-screen banner-message-text 'LEADER'
	# user_custom=$(grep "AutomaticLogin=" $REPO_DIR/gdm_conf/custom.conf | awk -F "=" '{print $2}')
	# user_local=$(whoami)
	sudo cp $REPO_DIR/custom.conf /etc/gdm
	# if [ "$user_custom" != "$user_local" ]; then
	# 	sudo sed -i "s/$user_custom/$user_local/g" /etc/gdm/custom.conf
	# fi
	cd $REPO_DIR
	sudo ./change-gdm-background /usr/share/backgrounds/rhel9-dark.jpg
}

gdm_config &>$HOME/Drive/logs/gdm_config.log

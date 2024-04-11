#!/bin/bash
# Clean Data
source variables.sh

clean_data() {
	cd $HOME/Drive
	gcm_file=$(ls gcm*)
	shfmt_file=$(ls shfmt*)
	rm -rf gnome-terminal install.sh $HOME/.oh-my-zsh/themes WhiteSur-gtk-theme WhiteSur-icon-theme WhiteSur-cursors ibus-bamboo fira-code fira-code.zip install-gnome-extensions.sh $gcm_file shfmt
	cd /usr/share/themes
	rhel_important=$(ls -d /usr/share/themes/rhel*alt)
	sudo mv $rhel_important /usr/share/themes/redhat-alt
	sudo rm -rf rhel*
	cd redhat-alt
	sudo rm -rf cinnamon plank gnome-shell
	sudo dnf autoremove vim-common vim-enhanced vi -y
	cd /usr/share/icons
	sudo rm -rf rhel-dark rhel-light
	cd $HOME
}

clean_data &>$HOME/Drive/logs/clean_data.log

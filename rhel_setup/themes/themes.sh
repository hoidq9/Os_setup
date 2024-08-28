#!/bin/bash
# Install Themes based MacOS for System
source variables.sh

themes() {
	sudo rm -rf /usr/share/themes/redhat-alt
	cd $HOME/Drive
	git clone https://github.com/vinceliuice/WhiteSur-gtk-theme.git
	# sudo dnf install vi -y
	cd WhiteSur-gtk-theme
	for target in background-default.png background-darken.png; do
		cp $REPO_DIR/intel-processor.jpg src/assets/gnome-shell/backgrounds/$target
	done
	# vi -u NONE -c 'g/&#panelActivities/normal! d%' -c 'wq' src/sass/gnome-shell/common/_panel.scss
	gawk -i inplace '!/Yaru/' src/main/gnome-shell/gnome-shell-theme.gresource.xml
	sudo ./install.sh -n 'rhel' -o normal -i gnome -c Dark -a alt -t default -p 60 -P smaller -s default -b default -m -N mojave -HD --normal --round --right
	sudo ./tweaks.sh -g default -o normal -c Dark -t default -p 60 -P smaller -n -i gnome -b default
	cd $REPO_DIR
	sudo cp intel-processor.jpg intel-core-i9.jpg Lenovo_Legion_Wallpaper.png /usr/share/backgrounds
	gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Lenovo_Legion_Wallpaper.png'
}

themes &>$HOME/Drive/logs/themes.log

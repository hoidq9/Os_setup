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
			if [ ! -f $HOME/.config/conky/conky.conf ]; then
				cp -f conky_text.conf /home/$user_current/.config/conky/conky.conf
			fi

		elif [ "$os_id" == "almalinux" ]; then
			if [ ! -f $HOME/.config/conky/conky.conf ]; then
				cp -f conky.conf /home/$user_current/.config/conky/
			fi
		fi

	elif [ "$os_id" == "rhel" ] && systemd-detect-virt | grep -q "none"; then

		mkdir -p /home/$user_current/Conky

		if [ ! -d /home/$user_current/.config/autostart ]; then
			mkdir -p /home/$user_current/.config/autostart
		fi

		cd $os_id

		if [ ! -f $HOME/Conky/conky_text.conf ] && [ ! -f $HOME/Conky/conky_cpu_graph.conf ] && [ ! -f $HOME/Conky/conky_uptodate.conf ]; then
			cp conky_cpu_graph.conf $HOME/Conky
			cp conky_text.conf $HOME/Conky
			cp conky_uptodate.conf $HOME/Conky
			cp *.sh $HOME/Conky
		fi

		curl -s https://api.github.com/repos/brndnmtthws/conky/releases/latest |
			grep "browser_download_url.*\\.AppImage\"" |
			head -n1 |
			cut -d '"' -f4 |
			xargs curl -L -o conky.AppImage

		mv conky.AppImage $HOME/Conky
		chmod +x $HOME/Conky/conky.AppImage

		sed -i "s/name_user_h/$user_current/g" conky.desktop

		if [ ! -d $HOME/.local/share/applications ]; then
			mkdir -p $HOME/.local/share/applications
		fi

		cp conky.desktop $HOME/.local/share/applications
		cp conky.desktop /home/$user_current/.config/autostart
		cp $REPO_DIR/start.sh $HOME/Conky
		chmod +x $HOME/Conky/start.sh

		loginctl enable-linger $user_current
	fi
}

if systemd-detect-virt | grep -q "none"; then
	if [[ $(<../../DesktopEnvironment.txt) == "KDE" ]]; then
		check_and_run Apps_Conky "$REPO_DIR/../../logs/Apps_Conky.log" "$REPO_DIR/../../logs/Result.log"
	fi
fi

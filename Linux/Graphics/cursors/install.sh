#!/bin/bash
source ../../variables.sh

cursors() {
	local name_os="$1"
	cd "$REPO_DIR" || return
	mkdir -p cursors_os
	cd cursors_os
	wget $(curl -s https://api.github.com/repos/ful1e5/apple_cursor/releases/latest | grep "browser_download_url.*macOS.tar.xz" | cut -d '"' -f 4) && tar -xvf macOS.tar.xz

	if [ "$EUID" -eq 0 ]; then
		mv macOS /usr/share/icons
		cd /usr/share/icons
		mv macOS ${name_os}_cursors
	fi

	if [ "$EUID" -ne 0 ]; then
		if [ ! -d "/usr/share/icons/${name_os}_cursors" ]; then
			mkdir -p /home/$user_current/.local/share/icons/
			mv macOS /home/$user_current/.local/share/icons/${name_os}_cursors
		fi
	fi

	cd "$REPO_DIR" || return
	rm -rf cursors_os
}

Graphics_cursors() {
	cursors "$os_id"
}

check_and_run Graphics_cursors "$REPO_DIR/../../logs/Graphics_cursors.log" "$REPO_DIR/../../logs/Result.log"

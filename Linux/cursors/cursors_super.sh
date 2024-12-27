#!/bin/bash
source ../variables.sh

cursors() {
	local name_os="$1"
	rm -rf /usr/share/icons/${name_os}_cursors
	cd "$REPO_DIR" || return
	mkdir -p cursors_os
	cd cursors_os
	wget $(curl -s https://api.github.com/repos/ful1e5/apple_cursor/releases/latest | grep "browser_download_url.*macOS.tar.xz" | cut -d '"' -f 4) && tar -xvf macOS.tar.xz
	cp -r macOS /usr/share/icons/
	cd /usr/share/icons/
	mv macOS ${name_os}_cursors
	cd "$REPO_DIR" || return
	rm -rf cursors_os
}

Main_cursors() {
	cursors "$os_id"
}

check_and_run Main_cursors

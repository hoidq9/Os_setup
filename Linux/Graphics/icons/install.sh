#!/bin/bash
source ../../variables.sh

icons() {
	local name_os="$1"
	cd $REPO_DIR
	mkdir -p icons_os
	cd icons_os
	mkdir -p WhiteSur-icon-theme && curl -L $(curl -s https://api.github.com/repos/vinceliuice/WhiteSur-icon-theme/releases/latest | grep "tarball" | cut -d '"' -f 4) | tar -xz -C WhiteSur-icon-theme --strip-components=1

	install_icons() {
		local target_dir=$1
		cd WhiteSur-icon-theme
		./install.sh -d $target_dir -n "${name_os}_icons" -t default -a -b
	}

	cleanup_icons() {
		local target_dir=$1
		cd "$target_dir"
		rm -rf "${name_os}_icons"-{dark,light}
	}

	if [ "$EUID" -eq 0 ]; then
		install_icons "/usr/share/icons"
		cleanup_icons "/usr/share/icons"
	else
		if [ ! -d "/usr/share/icons/${name_os}_icons" ]; then
			install_icons "$HOME/.icons"
			cleanup_icons "$HOME/.icons"
		fi
	fi

	cd $REPO_DIR
	rm -rf icons_os
}

Graphics_icons() {
	icons "$os_id"
}

check_and_run Graphics_icons "$REPO_DIR/../../logs/Graphics_icons.log" "$REPO_DIR/../../logs/Result.log"

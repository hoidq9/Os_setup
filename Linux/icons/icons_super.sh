#!/bin/bash
source ../variables.sh

icons() {
	local name_os="$1"
	cd $REPO_DIR
	mkdir -p icons_os
	cd icons_os
	mkdir -p WhiteSur-icon-theme && curl -L $(curl -s https://api.github.com/repos/vinceliuice/WhiteSur-icon-theme/releases/latest | grep "tarball" | cut -d '"' -f 4) | tar -xz -C WhiteSur-icon-theme --strip-components=1
	cd WhiteSur-icon-theme
	./install.sh -n "${name_os}_icons" -t default -a -b
	cd /usr/share/icons
	rm -rf ${name_os}_icons-{dark,light}
	cd $REPO_DIR
	rm -rf icons_os
}

main_icons() {
	icons "$os_id"
}

check_and_run main_icons
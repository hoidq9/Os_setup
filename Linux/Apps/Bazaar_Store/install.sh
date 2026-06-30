#!/bin/bash
source ../../variables.sh

Apps_Bazaar() {
	if [ "$os_id" == "rhel" ]; then
		flatpak install flathub io.github.kolunmi.Bazaar -y
	fi
}

check_and_run Apps_Bazaar "$REPO_DIR/../../logs/Apps_Bazaar.log" "$REPO_DIR/../../logs/Result.log"

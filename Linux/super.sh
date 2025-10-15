#!/bin/bash
source $(pwd)/variables.sh
# dnf upgrade -y &>/dev/null

cd $REPO_DIR/Wifi
sh install.sh

cd $REPO_DIR/System
sh install.sh

if systemd-detect-virt | grep -q "none"; then
	cd $REPO_DIR/Bootloader
	sh install.sh

	cd $REPO_DIR/Graphics/themes
	sh install.sh
fi

cd $REPO_DIR/Graphics/icons
sh install.sh

cd $REPO_DIR/Graphics/cursors
sh install.sh

cd $REPO_DIR/Apps/Font
sh install.sh

cd $REPO_DIR/System/gdm
sh install.sh

cd $REPO_DIR/Apps/Cursor
sh install.sh

cd $REPO_DIR/Apps/Gcm
sh install.sh

cd $REPO_DIR/Apps/Warp_Terminal
sh install.sh

cd $REPO_DIR/System
sh clean.sh

cd $REPO_DIR/Bootloader
sh grub_build.sh

chmod -R 777 $REPO_DIR/logs

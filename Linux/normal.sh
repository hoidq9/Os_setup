#!/bin/bash
source $(pwd)/variables.sh
flatpak update -y &>/dev/null

cd $REPO_DIR/Graphics/themes
sh install.sh

cd $REPO_DIR/Graphics/icons
sh install.sh

cd $REPO_DIR/Graphics/cursors
sh install.sh

cd $REPO_DIR/Apps/Font
sh install.sh

cd $REPO_DIR/Apps/Cursor
sh install.sh

cd $REPO_DIR/Apps/Conky
sh install.sh

cd $REPO_DIR/Apps/Gcm
sh install.sh

cd $REPO_DIR/Apps/Chrome
sh install.sh

cd $REPO_DIR/User
sh setup.sh

cd $REPO_DIR/Apps/Yubico
sh install.sh

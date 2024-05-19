#!/bin/bash
# Install Cursor based MacOS for System
source variables.sh

cursors() {
	cd $HOME/Drive/
	git clone https://github.com/vinceliuice/WhiteSur-cursors.git
	cd WhiteSur-cursors
	sudo ./install.sh
}
cursors &>$HOME/Drive/logs/cursors.log

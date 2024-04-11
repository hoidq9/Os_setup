#!/bin/bash
# Install Icons based MacOS for System
source variables.sh

icons() {
	cd $HOME/Drive
	git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
	cd WhiteSur-icon-theme
	sudo ./install.sh -n 'rhel' -t default -a -b
}

icons &>$HOME/Drive/logs/icons.log  
#!/bin/sh
source variables.sh

# Add custom command to remove kernel old
custom_cmd() {
	sudo cp $REPO_DIR/rmkernel /usr/bin
	sudo chmod +x /usr/bin/rmkernel
}

custom_cmd 
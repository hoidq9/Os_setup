#!/bin/bash
source ../../variables.sh

Apps_Chrome() {
    flatpak install flathub com.google.Chrome -y
}

# if [ "$os_id" == "rhel" ]; then
#     check_and_run Apps_Chrome "$REPO_DIR/../../logs/Apps_Chrome.log" "$REPO_DIR/../../logs/Result.log"
# fi

#!/bin/bash
source ../../variables.sh

Apps_Cockpit() {
    flatpak install flathub org.cockpit_project.CockpitClient -y
    mkdir -p /home/$user_current/.config/autostart
    cd $REPO_DIR
    cp -r org.cockpit_project.CockpitClient.desktop /home/$user_current/.config/autostart
}

# check_and_run Apps_Cockpit "$REPO_DIR/../../logs/Apps_Cockpit.log" "$REPO_DIR/../../logs/Result.log"

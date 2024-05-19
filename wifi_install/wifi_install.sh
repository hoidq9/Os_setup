#!/bin/bash
source variables.sh

wifi_install() {
	cd $REPO_DIR
	if nmcli device status | grep -q "wifi"; then
		wifi_rpms=("iw*" "wireless-regdb*" "wpa_supplicant*" "NetworkManager-wifi*")
		for rpm in "${wifi_rpms[@]}"; do
			wifi_file=$(ls $rpm 2>/dev/null | head -n 1)
			if [ -n "$wifi_file" ]; then
				sudo rpm -ivh $wifi_file
			else
				echo "No wifi rpm found"
				break
			fi
		done
		sudo systemctl restart NetworkManager
		sleep 30
		sudo dnf reinstall iw wireless-regdb wpa_supplicant NetworkManager-wifi -y
	fi
	sudo dnf upgrade -y
	sudo dnf install zsh git -y

}

wifi_install &>$HOME/Drive/logs/wifi_install.log

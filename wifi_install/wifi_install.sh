#!/bin/bash
source variables.sh

wifi_install() {
	if nmcli device status | grep -q "wifi"; then
		cd $REPO_DIR
		wifi_first=$(ls iw* 2>/dev/null | head -n 1)
		wifi_second=$(ls wireless-regdb* 2>/dev/null | head -n 1)
		wifi_third=$(ls wpa_supplicant* 2>/dev/null | head -n 1)
		wifi_fourth=$(ls NetworkManager-wifi* 2>/dev/null | head -n 1)
		if [ -n "$wifi_first" ]; then
			sudo rpm -ivh $wifi_first
		else
			echo "No wifi rpm found"
			break
		fi
		if [ -n "$wifi_second" ]; then
			sudo rpm -ivh $wifi_second
		else
			echo "No wifi rpm found"
			break
		fi
		if [ -n "$wifi_third" ]; then
			sudo rpm -ivh $wifi_third
		else
			echo "No wifi rpm found"
			break
		fi
		if [ -n "$wifi_fourth" ]; then
			sudo rpm -ivh $wifi_fourth
		else
			echo "No wifi rpm found"
			break
		fi
		sudo systemctl restart NetworkManager
		sleep 30
		sudo dnf reinstall iw wireless-regdb wpa_supplicant NetworkManager-wifi -y
	fi
	sudo dnf upgrade -y
	sudo dnf install zsh git -y

}

wifi_install &>$HOME/Drive/logs/wifi_install.log

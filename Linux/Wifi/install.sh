#!/bin/bash
source ../variables.sh

Wifi_download() {
    if rpm -q NetworkManager-wifi; then
        dnf upgrade -y iw wireless-regdb wpa_supplicant NetworkManager-wifi
        rm -rf iw* wireless-regdb* wpa_supplicant* NetworkManager-wifi*
        wifi_rpms=(
            "iw"
            "wireless-regdb"
            "wpa_supplicant"
            "NetworkManager-wifi"
        )
        for rpm in "${wifi_rpms[@]}"; do
            dnf download --downloadonly $rpm
        done
    else
        if nmcli device status | grep -q "wifi"; then
            wifi_rpms=(
                "iw*"
                "wireless-regdb*"
                "wpa_supplicant*"
                "NetworkManager-wifi*"
            )
            for rpm in "${wifi_rpms[@]}"; do
                wifi_file=$(ls $rpm 2>/dev/null | head -n 1)
                if [ -n "$wifi_file" ]; then
                    rpm -ivh $wifi_file
                else
                    echo "No wifi rpm found"
                    break
                fi
            done
            systemctl restart NetworkManager
            sleep 30
            dnf reinstall iw wireless-regdb wpa_supplicant NetworkManager-wifi -y
        fi
    fi
}

Wifi_install() {
    if [ "$os_id" = "almalinux" ] || [ "$os_id" = "rhel" ]; then
        cd $REPO_DIR/"$os_id"
        Wifi_download
    fi
}

check_and_run Wifi_install "$REPO_DIR/../logs/Wifi_install.log" "$REPO_DIR/../logs/Result.log"

#!/bin/bash
source ../variables.sh

wifi_packages() {
    if rpm -q NetworkManager-wifi; then
        dnf upgrade -y
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

cd $REPO_DIR/"$os_id"
check_and_run wifi_packages

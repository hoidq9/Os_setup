#!/bin/bash
GREEN='\033[0;32m'
echo
check_and_add_pam_u2f() {
    local pam_line="auth  sufficient  pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]"
    local pam_files=(
        "/etc/pam.d/gdm-password"
        "/etc/pam.d/system-auth"
        "/etc/pam.d/sshd"
    )

    for pam_file in "${pam_files[@]}"; do
        if ! grep -qF "$pam_line" "$pam_file"; then
            sudo sed -i "1s|^|$pam_line\n|" "$pam_file"
            echo "Added PAM U2F configuration to $pam_file"
        else
            echo "PAM U2F configuration already exists in $pam_file"
        fi
    done

    # setup bypass check gnome keyring
    sudo sed -i 's/^\(session\s\+optional\s\+pam_gnome_keyring\.so\s\+auto_start\b.*\)/#\1/' /etc/pam.d/gdm-password
}

echo -e "${GREEN}--- Listing FIDO2 devices... ---${NC}"
devices=$(systemd-cryptenroll --fido2-device=list)
echo
if [[ -n "$devices" ]]; then
    echo "$devices"
    echo
    read -p "Bạn có muốn sử dụng thiết bị FIDO2 để xác thực sudo không? (y/N): " choice
    case "$choice" in
    y | Y)
        echo -e "${GREEN}--- Install pam_u2f... ---${NC}"
        sudo dnf install pamu2fcfg -y
        echo
        echo -e "${GREEN}--- Enroll FIDO2 device... ---${NC}"
        pamu2fcfg >u2f_keys
        if [ ! -d "/Os_H" ]; then
            sudo mkdir /Os_H
        fi
        sudo mv u2f_keys /Os_H/Yubico_Auth
        check_and_add_pam_u2f
        sudo dnf remove pamu2fcfg -y &>/dev/null
        sudo dnf autoremove -y &>/dev/null
        sudo dnf install pam-u2f -y &>/dev/null
        ;;
    *)
        echo "Thoát chương trình."
        exit 0
        ;;
    esac
else
    echo "Không tìm thấy thiết bị FIDO2 nào. Thoát chương trình."
    exit 0
fi

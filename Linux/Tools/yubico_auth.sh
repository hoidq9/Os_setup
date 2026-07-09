#!/bin/bash
GREEN='\033[0;32m'
echo
source ../variables.sh

add_pam_u2f_gdm_password() {
	FILE="/etc/pam.d/gdm-password"
	LINE1='auth        sufficient pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]'
	LINE2='auth        sufficient pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]'

	# Kiểm tra nếu cả 2 dòng chưa có trong file
	if ! sudo grep -Fxq "$LINE1" "$FILE" && ! sudo grep -Fxq "$LINE2" "$FILE"; then
		# Chèn sau dòng chứa pam_selinux_permit.so
		sudo awk -v l1="$LINE1" -v l2="$LINE2" '
    {
        print
        if ($0 ~ /pam_selinux_permit\.so/) {
            print l1
            print l2
        }
    }' "$FILE" | sudo tee "${FILE}.tmp" >/dev/null
		sudo mv "${FILE}.tmp" "$FILE"
		echo "Đã chèn 2 dòng pam_u2f.so vào $FILE."
	else
		echo "2 dòng pam_u2f.so đã tồn tại trong $FILE, không thay đổi."
	fi
}

check_and_add_pam_u2f() {
	local pam_line="auth  sufficient  pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]"
	local pam_files=(
		# "/etc/pam.d/gdm-password"
		# "/etc/pam.d/system-auth"
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

}

authselect_auth() {
	if [ ! -d /etc/authselect/custom/user_auth ]; then
		sudo authselect create-profile user_auth --base-on=sssd
		sudo authselect select custom/user_auth --force

		FILE1="/etc/authselect/custom/user_auth/password-auth"
		FILE2="/etc/authselect/custom/user_auth/system-auth"
		LINE1='auth        sufficient pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]'
		LINE2='auth        sufficient pam_u2f.so  authfile=/Os_H/Yubico_Auth  cue [cue_prompt=Tap the Yubikey to authenticate]'

		if ! sudo grep -Fxq "$LINE1" "/etc/pam.d/password-auth" && ! sudo grep -Fxq "$LINE2" "/etc/pam.d/password-auth"; then
			if ! sudo grep -Fxq "$LINE1" "$FILE1" && ! sudo grep -Fxq "$LINE2" "$FILE1"; then
				sudo awk -v l1="$LINE1" -v l2="$LINE2" '
        {
            print
            if ($0 ~ /auth[[:space:]]+sufficient[[:space:]]+pam_u2f\.so[[:space:]]+cue/) {
                print l1
                print l2
            }
        }
    ' "$FILE1" | sudo tee "${FILE1}.tmp" >/dev/null
				sudo mv "${FILE1}.tmp" "$FILE1"
			fi
		fi

		if ! sudo grep -Fxq "$LINE1" "/etc/pam.d/system-auth" && ! sudo grep -Fxq "$LINE2" "/etc/pam.d/system-auth"; then
			if ! sudo grep -Fxq "$LINE1" "$FILE2" && ! sudo grep -Fxq "$LINE2" "$FILE2"; then
				sudo awk -v l1="$LINE1" -v l2="$LINE2" '
        {
            print
            if ($0 ~ /auth[[:space:]]+sufficient[[:space:]]+pam_u2f\.so[[:space:]]+cue/) {
                print l1
                print l2
            }
        }
    ' "$FILE2" | sudo tee "${FILE2}.tmp" >/dev/null
				sudo mv "${FILE2}.tmp" "$FILE2"
			fi
		fi
		sudo authselect apply-changes
	fi
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
		if rpm -q pamu2fcfg &>/dev/null; then
			sudo dnf upgrade -y
		else
			sudo dnf install pamu2fcfg -y
		fi
		echo
		echo -e "${GREEN}--- Enroll FIDO2 device... ---${NC}"

		if [ ! -f "/Os_H/Yubico_Auth" ]; then
			sudo mkdir /Os_H >/dev/null 2>&1
			sudo touch /Os_H/Yubico_Auth
		fi

		if grep -q "$user_current" /Os_H/Yubico_Auth 2>/dev/null; then
			echo "Thiết bị FIDO2 đã được đăng ký cho người dùng $user_current."
		else
			echo "Đăng ký thiết bị FIDO2 cho người dùng $user_current..."
			pamu2fcfg -u -V "$user_current" | sudo tee -a /Os_H/Yubico_Auth >/dev/null
		fi

		# add_pam_u2f_gdm_password
		# check_and_add_pam_u2f
		authselect_auth
		sudo dnf autoremove -y &>/dev/null
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

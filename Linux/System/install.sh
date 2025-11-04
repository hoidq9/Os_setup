#!/bin/bash

# If not install kernel from Elrepo, please disable E-core CPU in BIOS

# Install kernel from Elrepo for compatible with CPU Intel (RHEL and branches)
# sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# sudo yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y (RHEL 9)
# sudo yum --enablerepo=elrepo-kernel install kernel-ml -y
# sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms

shfmt_install() {
	mkdir -p shfmt_install
	cd shfmt_install || return
	curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep "browser_download_url" | grep "linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -i -
	mv * shfmt
	mv shfmt /usr/bin/
	chmod +x /usr/bin/shfmt
	cd ..
	rm -rf shfmt_install
}

# enpass_install() {
# 	# curl -s https://www.enpass.io/downloads/ | grep "stable/portable/linux" | grep "https" | sed -n 's/.*\(https[^"]*\).*/\1/p'
# 	cd "$REPO_DIR" || return
# 	cd /etc/yum.repos.d/
# 	rm -rf enpass-yum.repo
# 	wget https://yum.enpass.io/enpass-yum.repo
# 	dnf install enpass -y
# }

source ../variables.sh
[ ! -d /Os_H ] && mkdir -p /Os_H
grep -q "clean_requirements_on_remove=1" /etc/dnf/dnf.conf || echo -e "directive clean_requirements_on_remove=1" >>/etc/dnf/dnf.conf
cd $REPO_DIR/repo || return
cp vscode.repo microsoft-edge.repo /etc/yum.repos.d/ # yandex-browser.repo google-chrome.repo

create_keys_secureboot() {
	set -euo pipefail
	DAYS_VALID=1095 # 3 năm

	KEY_DIR="/keys"
	KEY_NAME="${os_id}-${user_current}"
	KEY_PATH="${KEY_DIR}/${KEY_NAME}.key"
	CERT_PATH="${KEY_DIR}/${KEY_NAME}.x509"

	# === 1. Chuẩn bị thư mục chứa khóa ===
	if [ ! -d "${KEY_DIR}" ]; then
		mkdir -p "${KEY_DIR}"
		chmod 700 "${KEY_DIR}"
	fi

	cd "${KEY_DIR}" || exit 1

	# === 2. Kiểm tra xem cần tạo mới hay không ===
	NEED_NEW_CERT=false

	# Nếu chưa có key hoặc cert → tạo mới
	if [ ! -f "${KEY_PATH}" ] || [ ! -f "${CERT_PATH}" ]; then
		NEED_NEW_CERT=true
	else
		# Nếu có cert rồi, kiểm tra xem có hết hạn chưa (7 ngày trước hạn thì tái tạo)
		if ! openssl x509 -checkend $((7 * 24 * 3600)) -noout -in "${CERT_PATH}" >/dev/null 2>&1; then
			echo "→ Chứng chỉ đã hết hạn hoặc sắp hết hạn. Sẽ tạo mới."
			NEED_NEW_CERT=true
		fi
	fi

	if [ "${NEED_NEW_CERT}" = true ]; then
		echo "Đang tạo mới ECC 521 keypair và chứng chỉ X.509…"

		# ==== 3. Sinh ECC Private key + Self-signed certificate ====
		SUBJECT="/C=VN/ST=Hanoi/L=Hanoi/O=VnH/OU=VnW/CN=${KEY_NAME}.com"

		openssl req -x509 \
			-newkey ec \
			-pkeyopt ec_paramgen_curve:secp521r1 \
			-pkeyopt ec_param_enc:named_curve \
			-sha512 \
			-days "${DAYS_VALID}" \
			-nodes \
			-keyout "${KEY_PATH}" \
			-out "${CERT_PATH}" \
			-subj "${SUBJECT}"

		# ==== 4. Xuất định dạng DER, PEM, PKCS#12 ====
		openssl x509 -in "${CERT_PATH}" -outform DER -out "${KEY_DIR}/${KEY_NAME}.der"
		openssl x509 -in "${KEY_DIR}/${KEY_NAME}.der" -inform DER -outform PEM -out "${KEY_DIR}/${KEY_NAME}.pem"

		openssl pkcs12 -export \
			-inkey "${KEY_PATH}" \
			-in "${CERT_PATH}" \
			-out "${KEY_DIR}/${KEY_NAME}.p12" \
			-name "${KEY_NAME}" \
			-passout pass:

		# Alias để tương thích
		cp "${KEY_PATH}" "${KEY_DIR}/${KEY_NAME}.priv"
		cp "${CERT_PATH}" "${KEY_DIR}/${KEY_NAME}.crt"

		# ==== 5. Quyền hạn ====
		chmod 600 "${KEY_PATH}" "${KEY_DIR}/${KEY_NAME}.p12"
		chmod 700 "${KEY_DIR}"

		if [ "$os_id" == "rhel" ] || [ "$os_id" == "fedora" ]; then
			dnf install pesign -y
			dnf upgrade -y pesign
			pk12util -d /etc/pki/pesign -i /keys/"${os_id}-${user_current}.p12" -W ""
		fi
		# ==== 6. Kiểm tra nhanh ====
		echo "Kiểm tra khóa và chứng chỉ ECC 521:"
		openssl ec -in "${KEY_PATH}" -noout -text | head -n 5 && echo "   …"
		openssl x509 -in "${CERT_PATH}" -noout -text | head -n 5 && echo "   …"

		echo "✅ Hoàn tất. Các file đã tạo tại ${KEY_DIR}:"
		echo "  • ${KEY_NAME}.key   (ECC private key, secp521r1)"
		echo "  • ${KEY_NAME}.x509  (Certificate X.509, SHA-512)"
		echo "  • ${KEY_NAME}.der   (Certificate DER)"
		echo "  • ${KEY_NAME}.pem   (Certificate PEM)"
		echo "  • ${KEY_NAME}.p12   (PKCS#12, chứa cả private key + cert)"
	else
		echo "✅ Chứng chỉ ECC 521 hiện tại vẫn còn hạn sử dụng, không cần tạo mới."
	fi
}

nvidia_drivers() {

	mkdir -p /NVIDIA
	device_id=$(lspci -nn | grep -i nvidia | grep VGA | sed 's/.*\[\([0-9a-fA-F:]\+\)\].*/\1/' | cut -d: -f2)

	if [ -z "$device_id" ]; then
		echo "❌ Không tìm thấy card NVIDIA nào trên hệ thống." >&2
		return 1
	fi

	driver_version=$(
		curl -s https://www.nvidia.com/en-us/drivers/unix/ |
			grep "Latest Production Branch Version:" |
			grep "Linux x86_64/AMD64/EM64T" |
			grep -Pzo '(?s)<span[^>]*>Latest Production Branch Version:</span>.*?<a[^>]*>\K[^<]+' |
			tr -d '\0[:space:]'
	)
	curl -s https://us.download.nvidia.com/XFree86/Linux-x86_64/$driver_version/README/supportedchips.html -o $REPO_DIR/supportedchips.html

	if grep -qoiw "$device_id" $REPO_DIR/supportedchips.html; then
		echo "✅ Card NVIDIA ($device_id) được hỗ trợ bởi driver $driver_version."

		CURRENT_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader || echo "0.0.0")
		BASE_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64"

		if [[ "$CURRENT_VERSION" < "$driver_version" ]]; then
			cd /NVIDIA || return 1
			RUN_FILE="NVIDIA-Linux-x86_64-${driver_version}.run"
			DOWNLOAD_URL="${BASE_URL}/${driver_version}/${RUN_FILE}"

			if [[ ! -f "$RUN_FILE" ]]; then
				wget --continue --show-progress "$DOWNLOAD_URL" -O "$RUN_FILE"
			fi

			if rpm -q dkms; then
				dkms status | grep nvidia | awk '{print $1}' | while read module; do
					dkms remove -m "$module" --all
				done
			fi

			bash "$RUN_FILE" -s --systemd --rebuild-initramfs --install-compat32-libs --allow-installation-with-running-driver --module-signing-secret-key=/keys/"${os_id}-${user_current}".key --module-signing-public-key=/keys/"${os_id}-${user_current}".x509 --no-x-check --dkms --install-libglvnd

		fi
	else
		echo "❌ Card NVIDIA ($device_id) không được hỗ trợ bởi driver $driver_version."
		return 1
	fi

	rm -rf $REPO_DIR/supportedchips.html
}

dkms_config() {
	if [ -d /etc/dkms ]; then
		if [ ! -f /etc/dkms/framework.conf ]; then
			touch /etc/dkms/framework.conf
		else
			grep -qxF 'mok_signing_key=/keys/'${os_id}-${user_current}'.key' /etc/dkms/framework.conf || echo 'mok_signing_key=/keys/'${os_id}-${user_current}'.key' | tee -a /etc/dkms/framework.conf
			grep -qxF 'mok_certificate=/keys/'${os_id}-${user_current}'.x509' /etc/dkms/framework.conf || echo 'mok_certificate=/keys/'${os_id}-${user_current}'.x509' | tee -a /etc/dkms/framework.conf
		fi
	fi
}

vscode_custom() {
	if rpm -q code && [ -f /usr/share/applications/code.desktop ]; then
		sed -i 's|^Exec=.*|Exec=bash -c '\''unset HOSTNAME; exec /usr/bin/code %F'\''|' /usr/share/applications/code.desktop
	fi
}

windsurf_custom() {
	if rpm -q windsurf && [ -f /usr/share/applications/windsurf.desktop ]; then
		sed -i 's|^Exec=.*|Exec=bash -c '\''unset HOSTNAME; exec /usr/bin/windsurf'\''|' /usr/share/applications/windsurf.desktop
	fi
}

# check if machine have nvidia gpu
install_gpu_driver() {
	if lspci | grep -qi nvidia; then
		if rpm -q dkms; then
			dnf upgrade dkms -y
		else
			dnf install dkms -y
		fi
		if rpm -q libglvnd-devel; then
			dnf upgrade libglvnd-devel -y
		else
			dnf install libglvnd-devel -y
		fi
		create_keys_secureboot
		dkms_config
	fi
	nvidia_drivers
}

sign_kernel_garuda() {
	sh $REPO_DIR/../Bootloader/mount_setup.sh
	if [ -f /boot/efi/EFI/Garuda/grubx64.efi ] && blkid | grep -q "btrfs"; then
		if rpm -q sbsigntools; then
			dnf upgrade sbsigntools -y
		else
			dnf install sbsigntools -y
		fi
		mkdir -p /mount_btrfs
		# get all partitions with btrfs filesystem
		partitions=$(lsblk -l -o NAME,FSTYPE | grep btrfs | awk '{print $1}')
		for partition in $partitions; do
			mkdir -p /mount_btrfs/$partition
			mount /dev/$partition /mount_btrfs/$partition
			if cat /mount_btrfs/$partition/@/etc/os-release | grep -q garuda; then
				create_keys_secureboot

				kernel_paths=(
					/mount_btrfs/$partition/@/boot/vmlinuz-linux
					/mount_btrfs/$partition/@/boot/vmlinuz-linux-zen
				)

				for kernel_path in "${kernel_paths[@]}"; do
					if [ -f "$kernel_path" ]; then
						sbverify --cert /keys/${os_id}-${user_current}.x509 "$kernel_path" &>/dev/null

						if [ $? -eq 0 ]; then
							echo "✓ Kernel đã được ký với khóa MOK: $(basename /keys/${os_id}-${user_current}.der)"
							continue
						elif [ $? -ne 0 ]; then
							sbsign --key /keys/${os_id}-${user_current}.priv --cert /keys/${os_id}-${user_current}.crt --output "${kernel_path}.signed" "$kernel_path"
							mv "${kernel_path}.signed" "${kernel_path}"
						fi

					fi
				done
			fi
			umount -l /mount_btrfs/$partition || true
		done
		rm -rf /mount_btrfs
	fi
}

sign_kernel_ubuntu() {
	dnf install pesign -y
	create_keys_secureboot
	os-prober | grep 'Ubuntu' | while IFS= read -r line; do
		device=$(echo "$line" | cut -d: -f1)
		type=$(echo "$line" | cut -d: -f4)
		if [ "$type" = "linux" ]; then
			mount_point="/mnt/ubuntu-mount"
			mkdir -p "$mount_point"
			mount "$device" "$mount_point"
			find $mount_point/boot/ -maxdepth 1 -type f -name 'vmlinuz-*-generic' -print0 |
				while IFS= read -r -d '' k; do
					# k có đường dẫn (./vmlinuz-...)
					if grep -q "${os_id}-${user_current}" <<<"$(pesign -S -i "$k")"; then
						echo "✅ Đã ký thành công: $k"
					else
						pesign --certificate "${os_id}-${user_current}" --in "$k" --sign --out "$k".signed
						mv "$k".signed "$k"
					fi
				done
			cd /mnt || return
			umount -l "$mount_point"
			# rm -rf "$mount_point"
		fi
	done
}

change_policy_keyring() {
	if rpm -q gdm; then
		sed -i '/password[[:space:]]\+optional[[:space:]]\+pam_gnome_keyring\.so use_authtok/ { /^[[:space:]]*#/! s/^/#/ }' /etc/pam.d/gdm-password
		sed -i '/session[[:space:]]\+optional[[:space:]]\+pam_gnome_keyring\.so[[:space:]]\+auto_start\b/ { /^[[:space:]]*#/! s/^/#/ }' /etc/pam.d/gdm-password
	fi
}

sys() {
	systemctl set-default graphical.target
	sh $REPO_DIR/cmd/rmkernel
	chsh -s /bin/zsh $user_current
}

services() {
	cd $REPO_DIR/conky_cpu
	cp *.sh /Os_H
	cp *.service /etc/systemd/system/
	systemctl enable cpu_power.service
	systemctl enable cpu_voltage.service
	systemctl start cpu_power.service
	systemctl start cpu_voltage.service
	chmod a-x,o-w '/etc/systemd/system/cpu_voltage.service'
	chmod a-x,o-w '/etc/systemd/system/cpu_power.service'
	if rpm -q cockpit; then
		systemctl enable cockpit.socket
		systemctl start cockpit.socket
		systemctl enable cockpit.service
		systemctl start cockpit.service
	fi
	systemctl daemon-reload
}

mount_windows_partition() {
	local partition_name="Windows_H"
	local mount_point="/Os_H/Windows_H"
	local partition_uuid=$(blkid -o value -s UUID -t LABEL="$partition_name")

	if mount | grep -q "$partition_name"; then
		echo "The partition is already mounted."
		return
	fi

	if blkid -o value -s TYPE -t LABEL="$partition_name" | grep -q "ntfs"; then
		mkdir -p "$mount_point"
		if ! grep -q "$partition_uuid" /etc/fstab; then
			echo "UUID=$partition_uuid  $mount_point  ntfs-3g  defaults,uid=$(id -u $user_current),gid=$(id -g $user_current),umask=022  0  0" >>/etc/fstab
		fi
		mount -a
	fi
}

cockpit_browser() {
	if rpm -q cockpit; then

		touch /etc/cockpit/allowed
		echo "$user_current" >/etc/cockpit/allowed
		chown root:root /etc/cockpit/allowed
		chmod 600 /etc/cockpit/allowed

		file=/etc/pam.d/cockpit

		pam1='auth [success=done default=ignore] pam_listfile.so item=user sense=allow file=/etc/cockpit/allowed onerr=fail'
		pam2='auth required pam_deny.so'

		for line in "$pam2" "$pam1"; do
			if ! grep -Fxq "$line" "$file"; then
				sed -i "1i $line" "$file"
			fi
		done
	fi
}

run() {
	packages
	sys
	cockpit_browser
	# if [ "$os_id" != "rhel" ]; then
	# 	mount_windows_partition
	# fi
}

create_uki_os_based_redhat() {

	current_kernel=$(uname -r)
	latest_kernel=$(rpm -q kernel --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" | sort -V | tail -n1)

	if [ ! -f /boot/linux_uki_based_redhat.efi ] || [ "$current_kernel" != "$latest_kernel" ]; then

		echo "add_dracutmodules+=\" fido2 \"" | tee /etc/dracut.conf.d/fido2.conf
		echo "add_dracutmodules+=\" tpm2-tss \"" | tee /etc/dracut.conf.d/tpm2.conf

		parameters=$(dracut --fstab --print-cmdline)

		dracut -v --kernel-cmdline " $parameters lockdown=confidentiality rd.shell=0 rd.emergency=halt" --uefi --kernel-image /usr/lib/modules/$latest_kernel/vmlinuz --force --ro-mnt --fstab --squash-compressor zstd -v /boot/linux_uki_based_redhat.efi

		pesign --in /boot/linux_uki_based_redhat.efi --out /boot/linux_uki_based_redhat.efi.signed --force --certificate "${os_id}-${user_current}" --sign
		mv /boot/linux_uki_based_redhat.efi.signed /boot/linux_uki_based_redhat.efi

		systemd-analyze pcrs >/home/$user_current/pcr_result_luks_tpm/result.txt
		awk '$1==4 || $1==7 || $1==11' /home/$user_current/pcr_result_luks_tpm/result.txt >/home/$user_current/pcr_result_luks_tpm/tmp && mv /home/$user_current/pcr_result_luks_tpm/tmp /home/$user_current/pcr_result_luks_tpm/result.txt

	fi

}

fedora_system() {
	repo_setup() {
		cp $REPO_DIR/repo/fedora_repositories.repo /etc/yum.repos.d/
	}
	packages() {
		dnf install ptyxis podman xapps gnome-shell git nautilus gnome-browser-connector gnome-system-monitor gdm git ibus-m17n zsh msr-tools conky dbus-x11 microsoft-edge-stable code gnome-disk-utility cockpit-podman cockpit kernel-devel flatpak gnome-software virt-manager -y # eza fzf pam_yubico gparted libXScrnSaver bleachbit keepassxc rclone xcb-util-keysyms xcb-util-renderutil baobab gnome-terminal gnome-terminal-nautilus flatpak kernel-devel
		dnf group install "hardware-support" "networkmanager-submodules" "fonts" -y                                                                                                                                                                                                   # "firefox"
		if blkid | grep -q "btrfs"; then
			dnf install btrfs-progs -y
		else
			if rpm -q btrfs-progs; then
				dnf remove btrfs-progs -y
			fi
		fi
		dnf upgrade -y
	}

	main() {
		repo_setup
		flatpak_repo() {
			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
		}
		run
		flatpak_repo
		create_keys_secureboot
		install_gpu_driver
		change_policy_keyring
		# sign_kernel_garuda
		vscode_custom
		services
		create_uki_os_based_redhat
	}
	main
}

rhel_system() {
	epel_check() {
		if ! rpm -q epel-release; then
			dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y # EPEL 10
		fi
	}

	flatpak_repo() {
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	}

	packages() {
		dnf install zsh gnome-shell gnome-browser-connector ptyxis nautilus PackageKit-command-not-found gnome-software gdm git dbus-x11 gnome-disk-utility gdb gcc seahorse gnome-system-monitor gnome-tweaks google-chrome-stable gnome-software flatpak -y # dconf-editor gnome-extensions-app.x86_64 yandex-browser-stable gnome-terminal gnome-terminal-nautilus chrome-gnome-shell podman-compose conky virt-manager redhat-mono-fonts rhc rhc-worker-playbook ansible-core yara
		dnf group install "Fonts" -y
		dnf upgrade -y
		# systemctl restart libvirtd
	}

	main() {
		cp $REPO_DIR/checksum/SHA1.pmod /etc/crypto-policies/policies/modules
		# update-crypto-policies --set LEGACY
		update-crypto-policies --set DEFAULT:SHA1
		epel_check
		run
		flatpak_repo
		install_gpu_driver
		change_policy_keyring
		if systemd-detect-virt | grep -q "none"; then
			cd $REPO_DIR/repo || return
			cp vscode.repo microsoft-edge.repo /etc/yum.repos.d/
			dnf install microsoft-edge-stable code ibus-m17n podman msr-tools cockpit-machines cockpit-podman cockpit kernel-devel -y
			shfmt_install
			services
		fi
		update-crypto-policies --set DEFAULT
		vscode_custom
		windsurf_custom
		sign_kernel_ubuntu
	}

	main
}

almalinux_system() {
	epel() {
		if ! rpm -q epel-release; then
			dnf install epel-release -y
		fi
	}
	packages() {
		dnf install gnome-terminal gnome-terminal-nautilus gnome-shell git nautilus gnome-disk-utility chrome-gnome-shell gnome-system-monitor gdm git dbus-x11 ibus-m17n zsh PackageKit-command-not-found gnome-software microsoft-edge-stable code podman-compose podman msr-tools virt-manager conky ntfs-3g redhat-mono-fonts -y # conky eza fzf
		dnf upgrade -y
		dnf group install "Fonts" -y
	}
	kernel() {
		dnf install elrepo-release -y
		yum --enablerepo=elrepo-kernel install kernel-ml -y
	}
	main() {
		epel
		run
		# kernel
	}
	main
}

System_install() {
	"$os_id"_system
}

check_and_run System_install "$REPO_DIR/../logs/System_install.log" "$REPO_DIR/../logs/Result.log"

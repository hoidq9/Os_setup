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
	DAYS_VALID=36500

	# Nếu chưa có thư mục /keys, tạo mới với quyền 700 ngay từ đầu
	if [ ! -d /keys ]; then
		mkdir -p /keys
		chmod 700 /keys
	fi

	cd /keys || exit 1

	# Nếu chưa có private .key, mới sinh
	if [ ! -f "${os_id}-${user_current}.key" ]; then

		# ==== CẤU HÌNH CHUNG ====
		SUBJECT="/C=Vn/ST=Hanoi/L=Hanoi/O=VnH/OU=VnW/CN=${os_id}-${user_current}.com"

		# 1. Tạo private key (RSA 4096 bit) và self-signed certificate (X.509, SHA-512)
		openssl req -x509 \
			-newkey rsa:4096 \
			-sha512 \
			-days "${DAYS_VALID}" \
			-nodes \
			-keyout "${os_id}-${user_current}.key" \
			-out "${os_id}-${user_current}.x509" \
			-subj "${SUBJECT}"

		# 2. Chuyển certificate PEM (.x509) sang DER (.der)
		openssl x509 \
			-in "${os_id}-${user_current}.x509" \
			-outform DER \
			-out "${os_id}-${user_current}.der"

		# 3. Chuyển từ DER trở lại PEM (.pem) – giống cert.pem
		openssl x509 \
			-in "${os_id}-${user_current}.der" \
			-inform DER \
			-outform PEM \
			-out "${os_id}-${user_current}.pem"

		# 4. Xuất một phần thông tin (để kiểm tra) nhưng chỉ hiển thị văn bản vài dòng đầu
		openssl rsa -in "${os_id}-${user_current}.key" -noout -text | head -n 5 && echo "   …"
		openssl x509 -in "${os_id}-${user_current}.x509" -noout -text | head -n 5 && echo "   …"
		openssl x509 -in "${os_id}-${user_current}.der" -inform DER -noout -text | head -n 5 && echo "   …"

		# 5. Tạo thêm file PKCS#12 (.p12) chứa private key + certificate,
		#    không đặt passphrase (pass empty) để dễ import vào NSS DB
		openssl pkcs12 -export \
			-inkey "${os_id}-${user_current}.key" \
			-in "${os_id}-${user_current}.x509" \
			-out "${os_id}-${user_current}.p12" \
			-name "${os_id}-${user_current}" \
			-passout pass:

		cp "${os_id}-${user_current}.key" "${os_id}-${user_current}.priv"
		cp "${os_id}-${user_current}.x509" "${os_id}-${user_current}.crt"

		# 6. Thiết lập quyền hạn chặt chẽ cho private key và file .p12
		chmod 600 "${os_id}-${user_current}.key" # chỉ owner có thể đọc/ghi private key
		chmod 600 "${os_id}-${user_current}.p12" # chỉ owner có thể đọc/ghi file PKCS#12
		chmod 700 /keys                          # chỉ owner có thể vào thư mục

		# 7. Import vào NSS DB (nếu cần)
		if [ "$os_id" == "rhel" ] || [ "$os_id" == "fedora" ]; then
			dnf install pesign -y
			dnf upgrade -y pesign
			pk12util -d /etc/pki/pesign -i /keys/"${os_id}-${user_current}.p12" -W ""
		fi

		# 7. Thông báo các file đã sinh
		echo "Hoàn thành! Bạn đã có các file trong /keys:"
		echo "  • ${os_id}-${user_current}.key   (Private key, PEM, không mã hóa passphrase)"
		echo "  • ${os_id}-${user_current}.x509  (Certificate, PEM X.509, SHA-512)"
		echo "  • ${os_id}-${user_current}.der   (Certificate, DER X.509)"
		echo "  • ${os_id}-${user_current}.pem   (Certificate PEM xuất từ DER)"
		echo "  • ${os_id}-${user_current}.p12   (PKCS#12, chứa cả private key và certificate)"

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
			grep -qxF 'mok_signing_key=/keys/'${os_id}-${user_current}'.key' /etc/dkms/framework.conf || echo 'mok_signing_key=/keys/'${os_id}-${user_current}'.key' | sudo tee -a /etc/dkms/framework.conf
			grep -qxF 'mok_certificate=/keys/'${os_id}-${user_current}'.x509' /etc/dkms/framework.conf || echo 'mok_certificate=/keys/'${os_id}-${user_current}'.x509' | sudo tee -a /etc/dkms/framework.conf
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
	cd $REPO_DIR/service
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

fedora_system() {
	repo_setup() {
		cp $REPO_DIR/repo/fedora_repositories.repo /etc/yum.repos.d/
	}
	packages() {
		dnf install ptyxis podman gnome-session-xsession xapps gnome-shell git nautilus gnome-browser-connector gnome-system-monitor gdm git ibus-m17n zsh msr-tools conky dbus-x11 microsoft-edge-stable code gnome-disk-utility cockpit-podman cockpit kernel-devel flatpak gnome-software -y # eza fzf pam_yubico gparted libXScrnSaver bleachbit keepassxc rclone xcb-util-keysyms xcb-util-renderutil baobab gnome-terminal gnome-terminal-nautilus flatpak kernel-devel
		dnf group install "hardware-support" "networkmanager-submodules" "fonts" -y                                                                                                                                                                                                             # "firefox"
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

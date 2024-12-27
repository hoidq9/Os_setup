#!/bin/bash

# If not install kernel from Elrepo, please disable E-core CPU in BIOS

# Install kernel from Elrepo for compatible with CPU Intel (RHEL and branches)
# sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# sudo yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y (RHEL 9)
# sudo yum --enablerepo=elrepo-kernel install kernel-ml -y
# sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms

# shfmt() {
#     mkdir -p $HOME/Drive/shfmt
#     cd $HOME/Drive/shfmt
#     curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep "browser_download_url" | grep "linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -i -
#     mv * shfmt
#     sudo mv shfmt /usr/bin/
#     sudo chmod +x /usr/bin/shfmt
# }

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
cp vscode.repo microsoft-edge.repo /etc/yum.repos.d/

gcm() {
	mkdir -p $REPO_DIR/gcm_install
	cd $REPO_DIR/gcm_install
	gcm_install() {
		curl -s https://api.github.com/repos/ldennington/git-credential-manager/releases/latest | grep -E 'browser_download_url.*gcm-linux.*[0-9].[0-9].[0-9].tar.gz' | cut -d : -f 2,3 | tr -d \" | xargs -I 'url' curl -LO 'url'
		gcm_file=$(ls gcm*.tar.gz)
		tar -xvf $gcm_file -C /usr/local/bin
		/usr/local/bin/git-credential-manager configure
	}
	if [ command -v git-credential-manager ] &>/dev/null; then
		/usr/local/bin/git-credential-manager unconfigure
		rm -rf $(command -v git-credential-manager)
		gcm_install
	else
		gcm_install
	fi
	git config --global credential.credentialStore secretservice
	rm -rf $REPO_DIR/gcm_install
}

sys() {
	systemctl set-default graphical.target
	sh $REPO_DIR/cmd/rmkernel
	chsh -s /bin/zsh $user_current
}

service_conky() {
	rm -rf /etc/systemd/system/cpu_power.service /etc/systemd/system/cpu_voltage.service
	cd $REPO_DIR/service
	cp * /etc/systemd/system/
	systemctl enable cpu_power.service
	systemctl enable cpu_voltage.service
	systemctl start cpu_power.service
	systemctl start cpu_voltage.service
	systemctl daemon-reload
}

config_conky() {
	if [ ! -d /home/$user_current/.config/autostart ]; then
		mkdir -p /home/$user_current/.config/autostart
	fi
	cd $REPO_DIR/conky
	rsync -av --exclude={conky1.conf,conky2.conf,conky3.conf,conky4.conf,conky5.conf,conky.desktop,conky.lua,conkyrc_conf_wayland,conkyrc_conf_xorg} * /Os_H
	cp conky.desktop /home/$user_current/.config/autostart
	chown -R $user_current:$user_current /home/$user_current/.config/autostart
	if loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "wayland"; then
		cp conkyrc_conf_wayland /etc/conky/conky.conf
	elif loginctl show-session $(loginctl list-sessions | grep $user_current | awk '{print $1}') -p Type | grep -q "x11"; then
		cp conkyrc_conf_xorg /etc/conky/conky.conf
	fi
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

run() {
	packages
	gcm
	sys
	service_conky
	config_conky
	mount_windows_partition
}

fedora_system() {
	repo_setup() {
		cp $REPO_DIR/repo/fedora_repositories.repo /etc/yum.repos.d/
	}
	packages() {
		dnf install podman gnome-session-xsession xapps gnome-terminal gnome-terminal-nautilus gnome-shell git nautilus gnome-disk-utility gnome-browser-connector gnome-system-monitor gdm git ibus-m17n jq zsh msr-tools conky dbus-x11 microsoft-edge-stable code -y # eza fzf cockpit pam_yubico gparted libXScrnSaver bleachbit keepassxc rclone xcb-util-keysyms xcb-util-renderutil baobab
		dnf group install "hardware-support" "networkmanager-submodules" -y                                                                                                                                                                                             # "firefox"
		dnf upgrade -y
	}
	main() {
		repo_setup
		run
	}
	main >>$REPO_DIR/../logs/fedora_system.log 2>&1
}
rhel_system() {
	epel_check() {
		if ! rpm -q epel-release; then
			sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y # EPEL 9
		fi
	}
	packages() {
		sudo dnf install zsh gnome-shell gnome-terminal gnome-terminal-nautilus nautilus gnome-disk-utility chrome-gnome-shell PackageKit-command-not-found gnome-software gnome-system-monitor gdm git dbus-x11 gcc gdb ibus-m17n jq microsoft-edge-stable code conky -y # podman-compose cockpit-podman cockpit-machines podman dconf-editor gnome-extensions-app.x86_64
	}
	main() {
		epel_check
		run
	}
	main >>$REPO_DIR/../logs/rhel_system.log 2>&1
}

check_and_run "$os_id"_system

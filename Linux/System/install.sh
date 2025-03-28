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
if [ "$os_id" == "almalinux" ] || [ "$os_id" == "fedora" ]; then
	cp google-chrome.repo yandex-browser.repo /etc/yum.repos.d/
fi

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

run() {
	packages
	sys
	services
	# if [ "$os_id" != "rhel" ]; then
	# 	mount_windows_partition
	# fi
}

fedora_system() {
	repo_setup() {
		cp $REPO_DIR/repo/fedora_repositories.repo /etc/yum.repos.d/
	}
	packages() {
		dnf install podman gnome-session-xsession xapps gnome-terminal gnome-terminal-nautilus gnome-shell git nautilus gnome-browser-connector gnome-system-monitor gdm git ibus-m17n zsh msr-tools conky dbus-x11 microsoft-edge-stable code -y # eza fzf cockpit pam_yubico gparted libXScrnSaver bleachbit keepassxc rclone xcb-util-keysyms xcb-util-renderutil baobab gnome-disk-utility
		dnf group install "hardware-support" "networkmanager-submodules" "fonts" -y                                                                                                                                                               # "firefox"
		dnf upgrade -y
	}
	main() {
		repo_setup
		run
	}
	main
}

rhel_system() {
	epel_check() {
		if ! rpm -q epel-release; then
			dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y # EPEL 9
		fi
	}

	flatpak_repo() {
		flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	}

	packages() {
		dnf install zsh gnome-shell gnome-terminal gnome-terminal-nautilus nautilus chrome-gnome-shell PackageKit-command-not-found gnome-software gdm git dbus-x11 ibus-m17n microsoft-edge-stable code podman-compose podman msr-tools redhat-mono-fonts cockpit-podman conky gnome-disk-utility rhc rhc-worker-playbook -y # dconf-editor gnome-extensions-app.x86_64 gdb cockpit-machines gcc yandex-browser-stable gnome-system-monitor google-chrome-stable virt-manager
		dnf group install "Fonts" -y
		systemctl restart libvirtd
	}

	main() {
		epel_check
		flatpak_repo
		run
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

#!/bin/bash
source variables.sh

system() {
	cd $REPO_DIR
	sudo cp rmkernel /usr/bin
	sudo chmod +x /usr/bin/rmkernel
	dir_general="$REPO_DIR/.."
	sudo find $dir_general -type f -print0 | sudo xargs -0 dos2unix --

	epel_check() {
		if ! rpm -q epel-release; then
			# sudo subscription-manager repos --enable codeready-builder-for-rhel-9-$(arch)-rpms
			# Extra Packages for Enterprise Linux 9 (EPEL)
			sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm -y
		fi
	}
	epel_check >>$HOME/Drive/logs/system.log 2>&1

	main() {
		sudo dnf install gnome-shell gnome-terminal gnome-terminal-nautilus nautilus gnome-disk-utility chrome-gnome-shell PackageKit-command-not-found gnome-software gnome-system-monitor gdm git dbus-x11 gcc gdb ibus-m17n jq -y # podman-compose cockpit-podman cockpit-machines podman dconf-editor
		sudo chsh -s /bin/zsh $USER
		if [ ! -d "$HOME/Drive" ]; then
			mkdir $HOME/Drive
		fi
		if ! grep -q "clean_requirements_on_remove=1" /etc/dnf/dnf.conf; then
			sudo sh -c 'echo -e "directive clean_requirements_on_remove=1" >> /etc/dnf/dnf.conf'
		fi
		sudo systemctl set-default graphical.target
		# sudo dnf autoremove cockpit -y
		# sudo systemctl enable --now cockpit.socket

		# Install new Kernel From Elrepo for compatible with CPU
		# sudo rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
		sudo yum install https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm -y
		sudo yum --enablerepo=elrepo-kernel install kernel-ml -y
	}
	main >>$HOME/Drive/logs/system.log 2>&1
}

system &>$HOME/Drive/logs/system.log

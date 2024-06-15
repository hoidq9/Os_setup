#!/bin/bash
# GRUB Configuration
source variables.sh

bootloader() {
	if [ ! -d /boot/grub2/themes ]; then
		sudo mkdir -p /boot/grub2/themes
	fi
	cd $REPO_DIR/..
	sudo cp -r bootloader /boot/grub2/themes
	if ! grep -q "/boot/grub2/themes/bootloader/theme.txt" /etc/default/grub; then
		sudo sh -c 'echo "GRUB_THEME=\"/boot/grub2/themes/bootloader/theme.txt\"" >> /etc/default/grub'
	fi
	# Set timeout to 20 seconds
	sudo sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=20/' /etc/default/grub
	sudo sed -i 's/^\(GRUB_TERMINAL\w*=.*\)/#\1/' /etc/default/grub
	sudo sed -i 's/GRUB_CMDLINE_LINUX="rhgb quiet"/GRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 cryptomgr.notests initcall_debug intel_iommu=igfx_off no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 tsc=reliable quiet splash\"/g' /etc/default/grub
	if ! grep -q "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" /etc/default/grub; then
		sudo sh -c 'echo -e "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" >> /etc/default/grub'
	fi
	sudo cp $REPO_DIR/30_uefi-firmware /etc/grub.d
	sudo chmod 755 /etc/grub.d/30_uefi-firmware
	sudo grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
}

bootloader &>$HOME/Drive/logs/bootloader.log

#!/bin/bash

source ../variables.sh
[ ! -d /boot/grub2/themes ] && mkdir -p /boot/grub2/themes
rm -rf /boot/grub2/themes/*
cp -f $REPO_DIR/30_uefi-firmware /etc/grub.d && chmod 755 /etc/grub.d/30_uefi-firmware
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=99/; s/^\(GRUB_TERMINAL\w*=.*\)/#\1; /g' /etc/default/grub
if ! grep -q "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" /etc/default/grub; then
	sh -c 'echo -e "GRUB_FONT=/boot/grub2/fonts/unicode.pf2" >> /etc/default/grub'
fi

fedora_bootloader() {
	cp -r $REPO_DIR/dedsec /boot/grub2/themes
	grep -q "/boot/grub2/themes/dedsec/theme.txt" /etc/default/grub || echo "GRUB_THEME=\"/boot/grub2/themes/dedsec/theme.txt\"" >>/etc/default/grub
}

rhel_bootloader() {
	cp -r $REPO_DIR/distro /boot/grub2/themes
	grep -q "/boot/grub2/themes/distro/theme.txt" /etc/default/grub || echo "GRUB_THEME=\"/boot/grub2/themes/distro/theme.txt\"" >>/etc/default/grub
	sed -i 's/GRUB_CMDLINE_LINUX="rhgb quiet"/GRUB_CMDLINE_LINUX_DEFAULT=\"intel_idle.max_cstate=1 cryptomgr.notests initcall_debug intel_iommu=igfx_off no_timer_check noreplace-smp page_alloc.shuffle=1 rcupdate.rcu_expedited=1 tsc=reliable quiet splash\"/g' /etc/default/grub
}

almalinux_bootloader() {
	cp -r $REPO_DIR/distro /boot/grub2/themes
	grep -q "/boot/grub2/themes/distro/theme.txt" /etc/default/grub || echo "GRUB_THEME=\"/boot/grub2/themes/distro/theme.txt\"" >>/etc/default/grub
}

Bootloader_themes() {
	sh $REPO_DIR/mount_setup.sh
	"$os_id"_bootloader
	sh $REPO_DIR/grub_setup.sh
}

check_and_run Bootloader_themes "$REPO_DIR/../logs/Bootloader_themes.log" "$REPO_DIR/../logs/Result.log"

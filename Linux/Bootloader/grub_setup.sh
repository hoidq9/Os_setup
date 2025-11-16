#!/bin/bash
RED='\033[0;31m'
NC='\033[0m'
if [ "$EUID" -ne 0 ]; then
	echo -e "${RED}This script must be run as root.${NC}"
	exit 1
fi

kernel_ver=$(rpm -q kernel | sort -V | tail -n1 | awk -F'kernel-' '{print $2}')
kernel_para=$(dracut --print-cmdline)
escaped_kernel_para=$(printf '%s' "$kernel_para" | sed 's/[&/\]/\\&/g')
boot_device=$(findmnt -no SOURCE /boot 2>/dev/null || df -P /boot | tail -1 | awk '{print $1}')
uuid_boot_unlocked=$(blkid -s UUID -o value "${boot_device}")
os_version=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)

source ../variables.sh

grub_new() {
	if [ "$os_id" = "rhel" ]; then
		# if blkid | grep -q "btrfs"; then
		# 	# Prepare
		# 	mkdir -p grub_efi
		# 	if ! rpm -q epel-release; then
		# 		dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y # EPEL 10
		# 	fi
		# 	dnf install btrfs-progs grub2-efi-x64-modules -y
		# 	dnf upgrade -y grub2-efi grub2-efi-x64-modules btrfs-progs

		# 	# Extract
		# 	cd grub_efi
		# 	dnf download --downloadonly grub2-efi
		# 	rpm_grub_efi=$(ls grub2-efi*.rpm)
		# 	rpm2cpio $rpm_grub_efi | cpio -idmv

		# 	# Environment variables
		# 	EFI_FILE="$(pwd)/boot/efi/EFI/redhat/grubx64.efi"
		# 	SBAT_SECTION="sbat.txt"
		# 	OUTPUT_FILE="sbat.csv"

		# 	# wget $(curl -s https://api.github.com/repos/kdave/btrfs-progs/releases/latest | grep browser_download_url | grep btrfs.static | cut -d '"' -f 4) -O btrfs
		# 	# mv btrfs /bin
		# 	# chmod +x /bin/btrfs

		# 	# Extract the .sbat section from the EFI file
		# 	objcopy --dump-section .sbat=$SBAT_SECTION $EFI_FILE

		# 	# Read the SBAT data from the section file and append to CSV
		# 	while IFS=',' read -r component_name component_generation vendor_name vendor_package_name vendor_version vendor_url; do
		# 		echo "$component_name,$component_generation,$vendor_name,$vendor_package_name,$vendor_version,$vendor_url" >>$OUTPUT_FILE
		# 	done <$SBAT_SECTION

		# 	# Create EFI images
		# 	grub2-mkimage -d /usr/lib/grub/x86_64-efi -p '' -o grubx64_new.efi -O x86_64-efi -c ../config_rhel.cfg -s $OUTPUT_FILE at_keyboard boot keylayouts usbserial_common usb serial usbserial_usbdebug usbserial_ftdi usbserial_pl2303 tpm chain efinet net backtrace connectefi lsefimmap lsefi efifwsetup efi_netfs zstd xfs fshelp version tftp test syslinuxcfg normal extcmd sleep terminfo search search_fs_uuid search_fs_file search_label regexp reboot png bitmap bufio pgp gcry_sha1 mpi pkcs1_v15 crypto password_pbkdf2 pbkdf2 gcry_sha512 part_gpt part_msdos part_apple minicmd mdraid1x diskfilter mdraid09 luks2 afsplitter cryptodisk json luks lvm linux loopback jpeg iso9660 increment http halt acpi mmap gzio gcry_crc gfxmenu video font gfxterm bitmap_scale trig video_colors gcry_whirlpool gcry_twofish gcry_sha256 gcry_serpent gcry_rsa gcry_rijndael fat f2fs ext2 echo procfs archelp configfile cat blscfg loadenv disk gettext datetime terminal priority_queue all_video video_bochs video_cirrus efi_uga efi_gop video_fb probe btrfs afs bfs hfs zfs multiboot multiboot2 ls lsmmap ntfs smbios loadbios tpm2_key_protector

		# 	if certutil -d /etc/pki/pesign -L | grep -qw "${os_id}-${user_current}"; then
		# 		pesign --in grubx64_new.efi --out grubx64.efi --certificate "${os_id}-${user_current}" --sign
		# 		mv grubx64.efi /boot/efi/EFI/redhat/
		# 	fi
		# 	# cd /boot/grub2/themes/bootloader
		# 	# rm -rf 30_uefi-firmware bootloader.sh config.cfg grub_custom refind_custom

		# 	# Clean
		# 	cd ..
		# 	rm -rf grub_efi # /bin/btrfs
		# # dnf autoremove grub2-efi-x64-modules -y

		# fi

		# dnf reinstall grub2-efi -y
		# if multiple packages are installed, remove the old ones
		for p in btrfs-progs grub2-efi-x64-modules; do # pesign
			rpm -q $p &>/dev/null && dnf remove -y $p
		done
		dnf autoremove -y

		cp $REPO_DIR/69_redhat /etc/grub.d/
		sed -i "s/(os_version)/$os_version/g" /etc/grub.d/69_redhat
		sed -i "s/(os_name)/$os_id/g" /etc/grub.d/69_redhat
		sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/69_redhat
		sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/69_redhat
		sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/69_redhat
		chmod +x /etc/grub.d/69_redhat

	elif [ "$os_id" = "fedora" ]; then
		if blkid | grep -q "btrfs"; then
			if rpm -q btrfs-progs &>/dev/null; then
				dnf upgrade btrfs-progs -y
			else
				dnf install btrfs-progs -y
			fi
		fi

		cp $REPO_DIR/1_fedora /etc/grub.d/
		sed -i "s/(os_version)/$os_version/g" /etc/grub.d/1_fedora
		sed -i "s/(os_name)/$os_id/g" /etc/grub.d/1_fedora
		sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/1_fedora
		sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/1_fedora
		sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/1_fedora
		chmod +x /etc/grub.d/1_fedora

	fi

	# if [ "$os_id" = "fedora" ]; then
	# 	grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
	# fi
	grub2-mkconfig -o /boot/grub2/grub.cfg

}

grub_new

echo "Hoàn thành cài đặt GRUB mới."

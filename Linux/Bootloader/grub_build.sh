#!/bin/bash
set -e
source ../variables.sh

if [ "$EUID" -ne 0 ]; then
	echo -e "${RED}This script must be run as root.${NC}"
	exit 1
fi

install_packages_dependencies() {

	if [ "$os_id" = "rhel" ]; then
		if ! rpm -q epel-release; then
			dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y # EPEL 10
		fi
		REPO="codeready-builder-for-rhel-10-$(arch)-rpms"
		dnf repolist enabled | grep -q "$REPO" || subscription-manager repos --enable "$REPO" -y # CRB 10
		dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm -y
		dnf install autoconf automake gettext-devel dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts fuse3 fuse3-devel libzfs5-devel libtasn1-devel device-mapper-devel make patch freetype-devel kernel-devel -y # unifont unifont-fonts ranlib

		unifont_otf() {
			BASE_URL="https://unifoundry.com/pub/unifont/"
			VERSIONS=$(curl -s "$BASE_URL" | grep -oP 'unifont-\d+\.\d+\.\d+/' | sed 's|/||g' | sort -V)
			LATEST_VERSION=$(echo "$VERSIONS" | tail -n 1)
			FILE_NAME="${LATEST_VERSION}.otf"
			DOWNLOAD_URL="${BASE_URL}${LATEST_VERSION}/font-builds/${FILE_NAME}"

			wget -O "$FILE_NAME" "$DOWNLOAD_URL"
			mv -f "$FILE_NAME" "unifont.otf"
			mkdir -p /usr/share/fonts/unifont
			mv -f "unifont.otf" /usr/share/fonts/unifont/
		}
		unifont_otf

	elif [ "$os_id" = "fedora" ]; then
		dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
		dnf install autoconf automake autopoint dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts ranlib fuse3 fuse3-devel libzfs6-devel libtasn1-devel device-mapper-devel unifont unifont-fonts make patch freetype-devel kernel-devel -y
	fi
	dnf upgrade -y
}

build_grub_image() {
	cd /home/$user_current/Prj/grub2
	if grep -q "GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY:" grub-core/kern/efi/sb.c; then

		install_packages_dependencies
		mkdir -p $(pwd)/../Grub
		./bootstrap
		./autogen.sh
		./configure --prefix="$(pwd)/../Grub" --with-platform=efi --target=x86_64 --enable-stack-protector --enable-mm-debug --enable-cache-stats --enable-boot-time --enable-grub-emu-sdl2 --enable-grub-emu-sdl --enable-grub-emu-pci --enable-grub-mkfont --enable-grub-themes --enable-grub-mount --enable-device-mapper --enable-liblzma --enable-libzfs --enable-grub-protect --with-gnu-ld --with-unifont=/usr/share/fonts/unifont/unifont.otf --with-dejavufont=/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf --enable-threads=posix+isoc --enable-cross-guesses=conservative --enable-dependency-tracking
		make install

		cp $REPO_DIR/config_grub.cfg $REPO_DIR/config_"$os_id".cfg
		cp $REPO_DIR/sbat_grub.csv $REPO_DIR/sbat_"$os_id".csv

		if [ "$os_id" = "rhel" ]; then
			sed -i "s/osname/redhat/g" $REPO_DIR/config_"$os_id".cfg
			grub_version_build=$(grep "grub_version" $(pwd)/../Grub/lib/grub/x86_64-efi/modinfo.sh | cut -d'"' -f2)
			sed -i "s/(version)/$grub_version_build/g" $REPO_DIR/sbat_"$os_id".csv
		fi

		cd $(pwd)/../Grub/bin
		./grub-mkimage -d ../lib/grub/x86_64-efi -p '' -o grubx64_new.efi -O x86_64-efi -c $REPO_DIR/config_"$os_id".cfg -s $REPO_DIR/sbat_"$os_id".csv at_keyboard boot keylayouts usbserial_common usb serial usbserial_usbdebug usbserial_ftdi usbserial_pl2303 tpm chain efinet net backtrace lsefimmap lsefi efifwsetup zstd xfs fshelp tftp test syslinuxcfg normal extcmd sleep terminfo search search_fs_uuid search_fs_file search_label regexp reboot png bitmap bufio pgp gcry_sha1 mpi crypto password_pbkdf2 pbkdf2 gcry_sha512 part_gpt part_msdos part_apple minicmd mdraid1x diskfilter mdraid09 luks2 afsplitter cryptodisk json luks lvm linux loopback jpeg iso9660 http halt acpi mmap gzio gcry_crc gfxmenu video font gfxterm bitmap_scale trig video_colors gcry_whirlpool gcry_twofish gcry_sha256 gcry_serpent gcry_rsa gcry_rijndael fat f2fs ext2 echo procfs archelp configfile cat loadenv disk gettext datetime terminal priority_queue all_video video_bochs video_cirrus efi_uga efi_gop video_fb probe btrfs afs bfs hfs zfs multiboot multiboot2 ls lsmmap ntfs smbios loadbios tpm2_key_protector

		cp grubx64_new.efi /boot/efi/EFI/redhat/grubx64.efi
		# rm -rf $REPO_DIR/config_"$os_id".cfg

	else
		echo "GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY not found in grub-core/kern/efi/sb.c, skipping build."
		exit 1
	fi
}

run() {
	if [ ! -d /home/$user_current/Prj ]; then
		mkdir -p /home/$user_current/Prj
	fi
	chown -R $user_current:$user_current /home/$user_current/Prj
	cd /home/$user_current/Prj

	if [ -d grub2/.git ]; then
		cd grub2
		BRANCH=$(git rev-parse --abbrev-ref HEAD)
		git fetch origin "$BRANCH"

		if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/$BRANCH)" ] || [ ! -f $(pwd)/../Grub/bin/grubx64_new.efi ]; then
			git pull
			build_grub_image
		fi
	else
		git clone -b master https://github.com/rhboot/grub2.git
		cd grub2
		build_grub_image
	fi
}

luks2_key_tpm2_protect() {
	mkdir -p /keys
	chmod 600 /keys
	cd /home/$user_current/Prj/Grub/bin
	if [ ! -f /keys/key_luks2 ]; then
		dd if=/dev/urandom of=/keys/key_luks2 bs=32 count=3
		chmod 600 /keys/key_luks2
	fi

	GREEN='\033[1;32m'
	RED='\033[0;31m'
	NC='\033[0m'

	if cryptsetup luksOpen --test-passphrase $1 --key-file=/keys/key_luks2 >/dev/null 2>&1; then
		echo -e $GREEN
		echo "LUKS2 device is already set up with the key file."
		echo -e $NC
	else
		echo $RED
		cryptsetup luksAddKey $1 /keys/key_luks2 --pbkdf=pbkdf2 --pbkdf-force-iterations=690298
		echo $NC
	fi

	./grub-protect --action=add --protector=tpm2 --tpm2-asymmetric=ECC --tpm2-bank=SHA256 --tpm2-keyfile=/keys/key_luks2 --tpm2-outfile=/boot/efi/EFI/seal.tpm --tpm2-pcrs=7 --tpm2key

}

main_script() {
	kernel_version=$(uname -r)
	vmlinuz_path="/boot/vmlinuz-${kernel_version}"
	initrd_path="/boot/initramfs-${kernel_version}.img"

	if [ ! -f "${vmlinuz_path}" ] || [ ! -f "${initrd_path}" ]; then
		echo "Lỗi: Không tìm thấy vmlinuz hoặc initrd cho kernel ${kernel_version}."
		exit 1
	fi
	boot_device=$(findmnt -no SOURCE /boot 2>/dev/null || df -P /boot | tail -1 | awk '{print $1}')
	root_device=$(findmnt -no SOURCE / 2>/dev/null || df -P / | tail -1 | awk '{print $1}')

	if [[ "${boot_device}" != "${root_device}" && "${boot_device}" == /dev/mapper/luks-* ]]; then

		if rpm -q git &>/dev/null; then
			echo "Git is already installed."
		else
			dnf install git -y
		fi

		source_device=$(cryptsetup status "${boot_device#/dev/mapper/}" | grep 'device:' | awk '{print $2}' | tr -d ' ')
		uuid_boot_locked=$(blkid -s UUID -o value "${source_device}")
		uuid_boot_unlocked=$(blkid -s UUID -o value "${boot_device}")
		os_version=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
		efi_device=$(findmnt -no SOURCE /boot/efi 2>/dev/null || df -P /boot/efi | tail -1 | awk '{print $1}')
		efi_uuid=$(blkid -s UUID -o value "$efi_device")
		kernel_ver=$(uname -r)
		kernel_para=$(dracut --print-cmdline)
		escaped_kernel_para=$(printf '%s' "$kernel_para" | sed 's/[&/\]/\\&/g')
		path_disk=$(blkid -U $uuid_boot_locked)

		cp $REPO_DIR/69_redhat /etc/grub.d/
		# sed -i 's|\$os_version|(os_version)|g; s|\$os_id|(os_name)|g; s|\$uuid_boot_locked|(boot_uuid)|g; s|\$uuid_boot_unlocked|(boot_mapper_uuid)|g; s|'"$(uname -r)"'|(kernel_version)|g; s|'"$(dracut --print-cmdline)"'|(kernel_parameters)|g; s|\$efi_uuid|(efi_uuid)|g' /etc/grub.d/69_redhat

		sed -i "s/(os_version)/$os_version/g" /etc/grub.d/69_redhat
		sed -i "s/(os_name)/$os_id/g" /etc/grub.d/69_redhat
		sed -i "s/(boot_uuid)/$uuid_boot_locked/g" /etc/grub.d/69_redhat
		sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/69_redhat
		sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/69_redhat
		sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/69_redhat
		sed -i "s/(efi_uuid)/$efi_uuid/g" /etc/grub.d/69_redhat

		run
		luks2_key_tpm2_protect "$path_disk"
		chmod +x /etc/grub.d/69_redhat
		grub2-mkconfig -o /boot/grub2/grub.cfg
		cp /boot/grub2/grub.cfg /boot/efi/EFI/redhat/grub.cfg
	fi
}

main_script

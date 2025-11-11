#!/bin/bash
set -e
source ../variables.sh

source_device=$(cryptsetup status "${boot_device#/dev/mapper/}" | grep 'device:' | awk '{print $2}' | tr -d ' ')
uuid_boot_locked=$(blkid -s UUID -o value "${source_device}")
uuid_boot_unlocked=$(blkid -s UUID -o value "${boot_device}")
os_version=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
efi_device=$(findmnt -no SOURCE /boot/efi 2>/dev/null || df -P /boot/efi | tail -1 | awk '{print $1}')
efi_uuid=$(blkid -s UUID -o value "$efi_device")
kernel_ver=$(rpm -q kernel | sort -V | tail -n1 | awk -F'kernel-' '{print $2}')
kernel_para=$(dracut --print-cmdline)
escaped_kernel_para=$(printf '%s' "$kernel_para" | sed 's/[&/\]/\\&/g')
path_disk=$(blkid -U $uuid_boot_locked)

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
		dnf install autoconf automake gettext-devel dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts fuse3 fuse3-devel libzfs5-devel libtasn1-devel device-mapper-devel make patch freetype-devel kernel-devel nss-tools pesign -y # unifont unifont-fonts ranlib

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
		# dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
		dnf install autoconf automake autopoint dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts ranlib fuse3 fuse3-devel libtasn1-devel device-mapper-devel unifont unifont-fonts make patch freetype-devel kernel-devel nss-tools pesign -y # libzfs6-devel
	fi
	dnf upgrade -y
}

build_grub_image() {
	cd /home/$user_current/Prj/grub2

	# Important
	grep -q 'GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY' grub-core/kern/efi/sb.c || sed -i '/\*flags = GRUB_VERIFY_FLAGS_SKIP_VERIFICATION;/i\  case GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY:' grub-core/kern/efi/sb.c

	install_packages_dependencies
	mkdir -p $(pwd)/../Grub
	./bootstrap
	./autogen.sh
	./configure --prefix="$(pwd)/../Grub" --with-platform=efi --target=x86_64 --enable-stack-protector --enable-mm-debug --enable-cache-stats --enable-boot-time --enable-grub-emu-sdl2 --enable-grub-emu-sdl --enable-grub-emu-pci --enable-grub-mkfont --enable-grub-mount --enable-device-mapper --enable-liblzma --enable-grub-protect --with-gnu-ld --with-unifont=/usr/share/fonts/unifont/unifont.otf --with-dejavufont=/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf --enable-threads=posix+isoc --enable-cross-guesses=conservative --enable-dependency-tracking # --enable-libzfs --enable-grub-themes
	make install

	cp $REPO_DIR/config_grub.cfg $REPO_DIR/config_"$os_id".cfg
	cp $REPO_DIR/sbat_grub.csv $REPO_DIR/sbat_"$os_id".csv

	if [ "$os_id" = "rhel" ]; then
		sed -i "s/osname/redhat/g" $REPO_DIR/config_"$os_id".cfg
		grub_version_build=$(grep "grub_version" $(pwd)/../Grub/lib/grub/x86_64-efi/modinfo.sh | cut -d'"' -f2)
		sed -i "s/(version)/$grub_version_build/g" $REPO_DIR/sbat_"$os_id".csv
	elif [ "$os_id" = "fedora" ]; then
		sed -i "s/osname/fedora/g" $REPO_DIR/config_"$os_id".cfg
		grub_version_build=$(grep "grub_version" $(pwd)/../Grub/lib/grub/x86_64-efi/modinfo.sh | cut -d'"' -f2)
		sed -i "s/(version)/$grub_version_build/g" $REPO_DIR/sbat_"$os_id".csv
	fi

	cd $(pwd)/../Grub/bin
	./grub-mkimage -d ../lib/grub/x86_64-efi -p '' -o grubx64_new.efi -O x86_64-efi -c $REPO_DIR/config_"$os_id".cfg -s $REPO_DIR/sbat_"$os_id".csv acpi adler32 affs afs afsplitter ahci all_video aout appleldr archelp argon2 argon2_test asn1 asn1_test ata at_keyboard backtrace bfs bitmap bitmap_scale bli blocklist blsuki boot boottime bsd bswap_test btrfs bufio cacheinfo cat cbfs cbls cbmemc cbtable cbtime chain cmosdump cmostest cmp cmp_test configfile cpio_be cpio cpuid crc64 cryptodisk crypto cs5536 ctz_test datehook date datetime diskfilter disk div div_test dm_nv dsa_sexp_test echo efifwsetup efi_gop efinet efitextmode efi_uga ehci elf erofs eval exfat exfctest ext2 extcmd f2fs fat file fixvideo font fshelp functional_test gcry_arcfour gcry_aria gcry_blake2 gcry_blowfish gcry_camellia gcry_cast5 gcry_crc gcry_des gcry_dsa gcry_gost28147 gcry_gostr3411_94 gcry_hwfeatures gcry_idea gcry_kdf gcry_keccak gcry_md4 gcry_md5 gcry_rfc2268 gcry_rijndael gcry_rmd160 gcry_rsa gcry_salsa20 gcry_seed gcry_serpent gcry_sha1 gcry_sha256 gcry_sha512 gcry_sm3 gcry_sm4 gcry_stribog gcry_tiger gcry_twofish gcry_whirlpool geli gettext gfxmenu gfxterm_background gfxterm gptsync gzio halt hashsum hdparm hello help hexdump hfs hfspluscomp hfsplus http iorw iso9660 jfs jpeg json keylayouts key_protector keystatus ldm legacycfg legacy_password_test linux16 linux loadbios loadenv loopback lsacpi lsefimmap lsefi lsefisystab lsmmap ls lspci lssal luks2 luks lvm lzopio macbless macho mdraid09_be mdraid09 mdraid1x memdisk memrw memtools minicmd minix2_be minix2 minix3_be minix3 minix_be minix mmap morse mpi msdospart mul_test multiboot2 multiboot nativedisk net newc nilfs2 normal ntfscomp ntfs odc offsetio ohci part_acorn part_amiga part_apple part_bsd part_dfly part_dvh part_gpt part_msdos part_plan part_sun part_sunpc parttool password password_pbkdf2 pata pbkdf2 pbkdf2_test pcidump pgp plainmount play png priority_queue probe procfs progress pubkey raid5rec raid6rec random rdmsr read reboot regexp reiserfs relocator romfs rsa_sexp_test scsi search_fs_file search_fs_uuid search_label search serial setjmp setjmp_test setpci sfs shift_test signature_test sleep sleep_test smbios spkmodem squash4 strtoull_test syslinuxcfg tar terminal terminfo test_blockarg testload test testspeed tftp tga time tpm2_key_protector tpm trig tr true tss2 udf ufs1_be ufs1 ufs2 uhci usb_keyboard usb usbms usbserial_common usbserial_ftdi usbserial_pl2303 usbserial_usbdebug usbtest video_bochs video_cirrus video_colors video_fb videoinfo video videotest_checksum videotest wrmsr xfs xnu xnu_uuid xnu_uuid_test xzio zstdio zstd

	if certutil -d /etc/pki/pesign -L | grep -qw "${os_id}-${user_current}"; then
		pesign --in grubx64_new.efi --out grubx64.efi --certificate "${os_id}-${user_current}" --sign
		if [ "$os_id" = "rhel" ]; then
			mv grubx64.efi /boot/efi/EFI/redhat/
		elif [ "$os_id" = "fedora" ]; then
			mv grubx64.efi /boot/efi/EFI/fedora/
		fi
	fi
	# rm -rf $REPO_DIR/config_"$os_id".cfg
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
		if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/$BRANCH)" ] || [ ! -d gnulib ]; then
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
	if [ ! -f /keys/key_important ]; then
		dd if=/dev/urandom of=/keys/key_important bs=16 count=8
		chmod 600 /keys/key_important
	fi

	GREEN='\033[1;32m'
	RED='\033[0;31m'
	NC='\033[0m'

	if cryptsetup luksOpen --test-passphrase $1 --key-file=/keys/key_important >/dev/null 2>&1; then
		echo -e $GREEN
		echo "LUKS2 device is already set up with the key file."
		echo -e $NC
	else
		echo -e $RED
		cryptsetup luksAddKey $1 /keys/key_important --pbkdf=pbkdf2 --pbkdf-force-iterations=628960 --hash=sha3-512
		echo -e $NC
	fi

	# tpm2_nvundefine -C o 0x1000001 || true
	# tpm2_evictcontrol -C o -c 0x81000009 || true
	# ./grub-protect --action=add --protector=tpm2 --tpm2-asymmetric=ECC --tpm2-bank=SHA256 --tpm2-keyfile=/keys/key_important --tpm2-pcrs=18 --tpm2-srk=0x81000009 --tpm2-nvindex=0x1000001 --tpm2key

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

		if [ "$os_id" = "rhel" ]; then
			cp $REPO_DIR/69_redhat /etc/grub.d/
			# sed -i 's|\$os_version|(os_version)|g; s|\$os_id|(os_name)|g; s|\$uuid_boot_locked|(boot_uuid)|g; s|\$uuid_boot_unlocked|(boot_mapper_uuid)|g; s|'"$(uname -r)"'|(kernel_version)|g; s|'"$(dracut --print-cmdline)"'|(kernel_parameters)|g; s|\$efi_uuid|(efi_uuid)|g' /etc/grub.d/69_redhat

			sed -i "s/(os_version)/$os_version/g" /etc/grub.d/69_redhat
			sed -i "s/(os_name)/$os_id/g" /etc/grub.d/69_redhat
			sed -i "s/(boot_uuid)/$uuid_boot_locked/g" /etc/grub.d/69_redhat
			sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/69_redhat
			sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/69_redhat
			sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/69_redhat
			sed -i "s/(efi_uuid)/$efi_uuid/g" /etc/grub.d/69_redhat
			chmod +x /etc/grub.d/69_redhat

		elif [ "$os_id" = "fedora" ]; then
			cp $REPO_DIR/1_fedora /etc/grub.d/
			cp $REPO_DIR/grub.cfg /boot/efi/EFI/fedora
			sed -i "s/(os_version)/$os_version/g" /etc/grub.d/1_fedora
			sed -i "s/(os_name)/$os_id/g" /etc/grub.d/1_fedora
			sed -i "s/(boot_uuid)/$uuid_boot_locked/g" /boot/efi/EFI/fedora/grub.cfg
			sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /boot/efi/EFI/fedora/grub.cfg
			sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/1_fedora
			sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/1_fedora
			sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/1_fedora
			sed -i "s/(efi_uuid)/$efi_uuid/g" /etc/grub.d/1_fedora
			chmod +x /etc/grub.d/1_fedora
		fi

		run
		luks2_key_tpm2_protect "$path_disk"
		grub2-mkconfig -o /boot/grub2/grub.cfg
	fi
}

# main_script
run

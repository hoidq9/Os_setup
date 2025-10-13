#!/bin/bash
source ../variables.sh

if [ ! -d $HOME/Prj ]; then
	mkdir -p $HOME/Prj
fi
cd $HOME/Prj

if [ "$os_id" = "rhel" ]; then
	if ! rpm -q epel-release; then
		sudo dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y # EPEL 10
	fi
	REPO="codeready-builder-for-rhel-10-$(arch)-rpms"
	sudo dnf repolist enabled | grep -q "$REPO" || sudo subscription-manager repos --enable "$REPO" -y # CRB 10
	sudo dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm -y
	sudo dnf install autoconf automake gettext-devel dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts fuse3 fuse3-devel libzfs5-devel libtasn1-devel device-mapper-devel make patch freetype-devel kernel-devel git -y # unifont unifont-fonts ranlib

	unifont_otf() {
		BASE_URL="https://unifoundry.com/pub/unifont/"
		VERSIONS=$(curl -s "$BASE_URL" | grep -oP 'unifont-\d+\.\d+\.\d+/' | sed 's|/||g' | sort -V)
		LATEST_VERSION=$(echo "$VERSIONS" | tail -n 1)
		FILE_NAME="${LATEST_VERSION}.otf"
		DOWNLOAD_URL="${BASE_URL}${LATEST_VERSION}/font-builds/${FILE_NAME}"

		wget -O "$FILE_NAME" "$DOWNLOAD_URL"
		mv -f "$FILE_NAME" "unifont.otf"
		sudo mkdir -p /usr/share/fonts/unifont
		sudo mv -f "unifont.otf" /usr/share/fonts/unifont/
	}
	unifont_otf

elif [ "$os_id" = "fedora" ]; then
	sudo dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
	sudo dnf install autoconf automake autopoint dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts ranlib fuse3 fuse3-devel libzfs6-devel libtasn1-devel device-mapper-devel unifont unifont-fonts make patch freetype-devel kernel-devel git -y
fi

if [ -d grub2/.git ]; then
	cd grub2
	git pull
else
	git clone -b master https://github.com/rhboot/grub2.git
	cd grub2
fi

mkdir -p $(pwd)/../Grub
./bootstrap
./autogen.sh
./configure --prefix="$(pwd)/../Grub" --with-platform=efi --target=x86_64 --enable-stack-protector --enable-mm-debug --enable-cache-stats --enable-boot-time --enable-grub-emu-sdl2 --enable-grub-emu-sdl --enable-grub-emu-pci --enable-grub-mkfont --enable-grub-themes --enable-grub-mount --enable-device-mapper --enable-liblzma --enable-libzfs --enable-grub-protect --with-gnu-ld --with-unifont=/usr/share/fonts/unifont/unifont.otf
make install

cd $(pwd)/../Grub/bin
./grub-mkimage -d ../lib/grub/x86_64-efi -p '' -o grubx64_new.efi -O x86_64-efi -c $REPO_DIR/config_rhel.cfg -s $REPO_DIR/sbat.csv at_keyboard boot keylayouts usbserial_common usb serial usbserial_usbdebug usbserial_ftdi usbserial_pl2303 tpm chain efinet net backtrace connectefi lsefimmap lsefi efifwsetup efi_netfs zstd xfs fshelp version tftp test syslinuxcfg normal extcmd sleep terminfo search search_fs_uuid search_fs_file search_label regexp reboot png bitmap bufio pgp gcry_sha1 mpi pkcs1_v15 crypto password_pbkdf2 pbkdf2 gcry_sha512 part_gpt part_msdos part_apple minicmd mdraid1x diskfilter mdraid09 luks2 afsplitter cryptodisk json luks lvm linux loopback jpeg iso9660 increment http halt acpi mmap gzio gcry_crc gfxmenu video font gfxterm bitmap_scale trig video_colors gcry_whirlpool gcry_twofish gcry_sha256 gcry_serpent gcry_rsa gcry_rijndael fat f2fs ext2 echo procfs archelp configfile cat blscfg loadenv disk gettext datetime terminal priority_queue all_video video_bochs video_cirrus efi_uga efi_gop video_fb probe btrfs afs bfs hfs zfs multiboot multiboot2 ls lsmmap ntfs smbios loadbios tpm2_key_protector
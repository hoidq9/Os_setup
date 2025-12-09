#!/bin/bash
dnf upgrade -y

REPO_DIR="$(dirname "$(readlink -m "${0}")")"
os_version=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
os_id=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
kernel_ver=$(rpm -q kernel | sort -V | tail -n1 | awk -F'kernel-' '{print $2}')
kernel_para=$(dracut --print-cmdline)
escaped_kernel_para=$(printf '%s' "$kernel_para" | sed 's/[&/\]/\\&/g')
uuid_boot_locked=$(uuidgen)
uuid_boot_unlocked=$(uuidgen)
user_current=$(logname)
GREEN='\033[1;32m'
NC='\033[0m'

mkdir -p /keys/key_luks2_tpm2_pcr

if [ ! -f /keys/key_luks2_tpm2_pcr/key.bin ]; then
	dd if=/dev/urandom of=/keys/key_luks2_tpm2_pcr/key.bin bs=16 count=8
	dd if=/dev/urandom of=/keys/key_luks2_tpm2_pcr/key_root.bin bs=16 count=8
	chmod 600 /keys/key_luks2_tpm2_pcr/key.bin
	chmod 600 /keys/key_luks2_tpm2_pcr/key_root.bin
fi

root_dev=$(findmnt -no SOURCE /)
boot_dev=$(findmnt -no SOURCE /boot 2>/dev/null || true)

if grep -q "/dev/mapper/" <<<"$boot_dev"; then
	isLuksBoot=true
else
	isLuksBoot=false
fi

if grep -q "/dev/mapper/" <<<"$root_dev"; then
	isLuksRoot=true
else
	isLuksRoot=false
fi

if [ "$os_id" = "rhel" ]; then
	if ! rpm -q epel-release; then
		dnf install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm -y # EPEL 10
	fi
	REPO="codeready-builder-for-rhel-10-$(arch)-rpms"
	dnf repolist enabled | grep -q "$REPO" || subscription-manager repos --enable "$REPO" # CRB 10
	# dnf install https://zfsonlinux.org/epel/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm -y
	dnf install autoconf automake gettext-devel dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts fuse3 fuse3-devel libtasn1-devel device-mapper-devel make patch freetype-devel kernel-devel nss-tools pesign tpm2-tss-devel libfdisk-devel -y # unifont unifont-fonts ranlib libzfs5-devel

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
	dnf install -y tpm2-tss-devel git json-c-devel util-linux pkg-config gcc make libfdisk-devel cryptsetup autoconf automake autopoint dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts ranlib fuse3 fuse3-devel libtasn1-devel device-mapper-devel unifont unifont-fonts patch freetype-devel kernel-devel nss-tools pesign sbsigntools libtool autoconf-archive
fi

dnf upgrade -y
ln -s /usr/lib64/pkgconfig/json-c.pc /usr/lib64/pkgconfig/json.pc

mapfile -t lines < <(awk '!/^#/ && ($2=="/boot") {print $1, $2, $3}' /etc/fstab)
mapfile -t lines1 < <(awk '!/^#/ && ($2=="/boot/efi") {print $1, $2, $3}' /etc/fstab)
# mapfile -t lines2 < <(awk '!/^#/ && ($2=="/") {print $1, $2, $3}' /etc/fstab)

# if ((${#lines2[@]})); then
# 	read -r deviceSpec2 mountPoint2 fsType2 <<<"${lines2[0]}"
# fi

# if [[ "$deviceSpec2" == UUID=* ]]; then
# 	uuid_root="${deviceSpec2#UUID=}"
# elif [[ "$deviceSpec2" == PARTUUID=* ]]; then
# 	uuid_root="${deviceSpec2#PARTUUID=}"
# fi

if ((${#lines1[@]})); then
	read -r deviceSpec1 mountPoint1 fsType1 <<<"${lines1[0]}"
fi
echo "$mountPoint1"
echo "$fsType1"

if [[ "$deviceSpec1" == UUID=* ]]; then
	uuid_efi="${deviceSpec1#UUID=}"
elif [[ "$deviceSpec1" == PARTUUID=* ]]; then
	uuid_efi="${deviceSpec1#PARTUUID=}"
fi

if ((${#lines[@]})); then
	read -r deviceSpec mountPoint fsType <<<"${lines[0]}"
fi
echo "$mountPoint"

if [[ "$deviceSpec" == UUID=* ]]; then
	uuid_old="${deviceSpec#UUID=}"
	dev=$(readlink -f "/dev/disk/by-uuid/$uuid_old" 2>/dev/null || true)
elif [[ "$deviceSpec" == PARTUUID=* ]]; then
	partuuid="${deviceSpec#PARTUUID=}"
	dev=$(readlink -f "/dev/disk/by-partuuid/$partuuid" 2>/dev/null || true)
else
	dev="$deviceSpec"
fi

get_real_backing() {
	dev="$1"

	while true; do
		base=$(basename "$(readlink -f "$dev")")
		slaves=(/sys/block/"$base"/slaves/*)

		# Nếu không có slave → đây là thiết bị thật (nvme, sda…)
		if [ ! -e "${slaves[0]}" ]; then
			echo "$dev"
			return
		fi

		# Lấy slave đầu tiên
		slave=$(basename "${slaves[0]}")
		dev="/dev/$slave"
	done
}

create_one_time_file_enc_sha256() {
	mkdir -p /home/$user_current/repos/one_time_file_enc_sha256
	cd /home/$user_current/repos/one_time_file_enc_sha256 || return

	R=/dev/urandom
	# tạo file ngẫu nhiên 1 MiB
	dd if=$R of=one_time_random.bin bs=1M count=1
	# tạo key 32 bytes và IV 16 bytes
	head -c32 $R >k
	head -c16 $R >iv
	K=$(xxd -p -c64 k)
	IV=$(xxd -p -c32 iv)
	# mã hoá AES-256-CTR
	openssl enc -aes-256-ctr -K "$K" -iv "$IV" -in one_time_random.bin -out one_time_random.bin.enc
	# tạo file expected.sha256 cho GRUB
	sha256sum one_time_random.bin.enc >expected.sha256
	# xoá key, IV và plaintext
	(shred -u k iv one_time_random.bin 2>/dev/null || rm -f k iv one_time_random.bin)
}

grub2_bootloader_setup() {

	if [ "$isLuksBoot" == true ]; then

		build_grubx64_image() {
			grep -q 'GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY' grub-core/kern/efi/sb.c || sed -i '/\*flags = GRUB_VERIFY_FLAGS_SKIP_VERIFICATION;/i\  case GRUB_FILE_TYPE_CRYPTODISK_ENCRYPTION_KEY:' grub-core/kern/efi/sb.c
			./bootstrap
			./autogen.sh
			./configure --prefix="/home/$user_current/repos/Grub2" --with-platform=efi --target=x86_64 --enable-stack-protector --enable-mm-debug --enable-cache-stats --enable-boot-time --enable-grub-emu-sdl2 --enable-grub-emu-sdl --enable-grub-emu-pci --enable-grub-mkfont --enable-grub-mount --enable-device-mapper --enable-liblzma --enable-grub-protect --with-gnu-ld --with-unifont=/usr/share/fonts/unifont/unifont.otf --with-dejavufont=/usr/share/fonts/dejavu-sans-fonts/DejaVuSans.ttf --enable-threads=posix+isoc --enable-cross-guesses=conservative --enable-dependency-tracking # --enable-libzfs --enable-grub-themes
			make install

			cp "$REPO_DIR"/config_grub.cfg /home/$user_current/repos/Grub2/bin/config_"$os_id".cfg
			cp "$REPO_DIR"/sbat_grub.csv /home/$user_current/repos/Grub2/bin/sbat_"$os_id".csv

			grub_version_build=$(grep "grub_version" /home/$user_current/repos/Grub2/lib/grub/x86_64-efi/modinfo.sh | cut -d'"' -f2)
			sed -i "s/(version)/$grub_version_build/g" /home/$user_current/repos/Grub2/bin/sbat_"$os_id".csv
			sed -i "s/(efi_uuid)/$uuid_efi/g" /home/$user_current/repos/Grub2/bin/config_"$os_id".cfg

			boot_real=$(get_real_backing "$boot_dev")
			uuid_boot_luks_locked=$(cryptsetup luksUUID "$boot_real")
			mapped_name=$(basename "$boot_dev")
			uuid_boot_luks_unlocked=$(blkid -s UUID -o value "/dev/mapper/$mapped_name")

			sed -i "s/(boot_locked_uuid)/$uuid_boot_luks_locked/g" /home/$user_current/repos/Grub2/bin/config_"$os_id".cfg
			sed -i "s/(boot_unlocked_uuid)/$uuid_boot_luks_unlocked/g" /home/$user_current/repos/Grub2/bin/config_"$os_id".cfg

			cd /home/$user_current/repos/Grub2/bin || return
			./grub-mkimage -d ../lib/grub/x86_64-efi -p '' -o grubx64_new.efi -O x86_64-efi -c config_"$os_id".cfg -s sbat_"$os_id".csv at_keyboard boot keylayouts usbserial_common usb serial usbserial_usbdebug usbserial_ftdi usbserial_pl2303 tpm chain efinet net backtrace lsefimmap lsefi efifwsetup zstd xfs fshelp tftp test syslinuxcfg normal extcmd sleep terminfo search search_fs_uuid search_fs_file search_label regexp reboot png bitmap bufio pgp gcry_sha1 mpi crypto password_pbkdf2 pbkdf2 gcry_sha512 part_gpt part_msdos part_apple minicmd mdraid1x diskfilter mdraid09 luks2 afsplitter cryptodisk json luks lvm linux loopback jpeg iso9660 http halt acpi mmap gzio gcry_crc gfxmenu video font gfxterm bitmap_scale trig video_colors gcry_whirlpool gcry_twofish gcry_sha256 gcry_serpent gcry_rsa gcry_rijndael fat f2fs ext2 echo procfs archelp configfile cat loadenv disk gettext datetime terminal priority_queue all_video video_bochs video_cirrus efi_uga efi_gop video_fb probe btrfs afs bfs hfs zfs multiboot multiboot2 ls lsmmap ntfs smbios loadbios tpm2_key_protector usb_keyboard hashsum test

			if [ "$os_id" == "fedora" ]; then
				sbsign --key /keys/secureboot/"${os_id}"-"${user_current}".key --cert /keys/secureboot/"${os_id}"-"${user_current}".crt grubx64_new.efi --output grubx64.efi
				cp grubx64.efi /boot/efi/EFI/fedora/
			elif [ "$os_id" == "rhel" ]; then
				pesign --in grubx64_new.efi --out grubx64.efi --certificate "${os_id}-${user_current}" --sign --force
				cp grubx64.efi /boot/efi/EFI/redhat/
			fi
		}

		mkdir -p /home/$user_current/repos/Grub2
		cd /home/$user_current/repos || return
		if [ -d grub2/.git ]; then
			cd grub2 || return
			BRANCH=$(git rev-parse --abbrev-ref HEAD)
			git fetch origin "$BRANCH"
			if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/"$BRANCH")" ] || [ ! -d gnulib ]; then
				git pull
				build_grubx64_image
			fi
		else
			git clone -b master https://github.com/rhboot/grub2.git
			cd grub2 || return
			build_grubx64_image
		fi
	fi
}

pcr_oracle_tpm2_seal() {

	if [ "$isLuksBoot" == true ]; then
		build_sealed_tpm() {
			./configure
			make install

			cd /keys/key_luks2_tpm2_pcr || return

			pcr-oracle --rsa-generate-key --private-key my-priv.pem --authorized-policy my-auth.policy create-authorized-policy 0,4,7,14

			pcr-oracle --target-platform tpm2.0 --authorized-policy my-auth.policy --input key.bin --output unsigned.tpm seal-secret

			pcr-oracle --policy-name authorized-policy-test --input unsigned.tpm --output sealed.tpm --target-platform tpm2.0 --algorithm sha256 --private-key my-priv.pem --from eventlog --stop-event "grub-file=grub.cfg" --before sign 0,4,7,14

			cp sealed.tpm /boot/efi/

		}

		mkdir -p /home/$user_current/repos
		cd /home/$user_current/repos || return
		if [ -d pcr-oracle/.git ]; then
			cd pcr-oracle || return
			BRANCH=$(git rev-parse --abbrev-ref HEAD)
			git fetch origin "$BRANCH"
			if [ "$(git rev-parse HEAD)" != "$(git rev-parse origin/"$BRANCH")" ]; then
				git pull
				build_sealed_tpm
			fi

		else
			git clone https://github.com/openSUSE/pcr-oracle.git
			cd pcr-oracle || return
			build_sealed_tpm
		fi
	fi
}

create_keys_secureboot() {
	# set -euo pipefail
	DAYS_VALID=1095

	# Nếu chưa có thư mục /keys/secureboot, tạo mới với quyền 700 ngay từ đầu
	if [ ! -d /keys/secureboot ]; then
		mkdir -p /keys/secureboot
		chmod 700 /keys/secureboot
	fi

	cd /keys/secureboot || exit 1

	NEED_NEW_CERT=false

	# Nếu chưa có key hoặc cert → tạo mới
	if [ ! -f "${os_id}-${user_current}.key" ]; then
		NEED_NEW_CERT=true
	else
		# Nếu có cert rồi, kiểm tra xem có hết hạn chưa (7 ngày trước hạn thì tái tạo)
		if ! openssl x509 -checkend $((7 * 24 * 3600)) -noout -in "${os_id}-${user_current}.x509" >/dev/null 2>&1; then
			echo "→ Chứng chỉ đã hết hạn hoặc sắp hết hạn. Sẽ tạo mới."
			NEED_NEW_CERT=true
		fi
	fi

	# Nếu chưa có private .key, mới sinh
	if [ "${NEED_NEW_CERT}" = true ]; then

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
		chmod 700 /keys/secureboot               # chỉ owner có thể vào thư mục

		# 7. Import vào NSS DB (nếu cần)
		if [ "$os_id" == "rhel" ] || [ "$os_id" == "fedora" ]; then
			dnf install pesign -y
			dnf upgrade -y pesign
			pk12util -d /etc/pki/pesign -i /keys/secureboot/"${os_id}-${user_current}.p12" -W ""
		fi

		# 7. Thông báo các file đã sinh
		echo "Hoàn thành! Bạn đã có các file trong /keys/secureboot:"
		echo "  • ${os_id}-${user_current}.key   (Private key, PEM, không mã hóa passphrase)"
		echo "  • ${os_id}-${user_current}.x509  (Certificate, PEM X.509, SHA-512)"
		echo "  • ${os_id}-${user_current}.der   (Certificate, DER X.509)"
		echo "  • ${os_id}-${user_current}.pem   (Certificate PEM xuất từ DER)"
		echo "  • ${os_id}-${user_current}.p12   (PKCS#12, chứa cả private key và certificate)"
	fi

	mokutil --import /keys/secureboot/"${os_id}-${user_current}.der"
}

create_luks2_boot_partition() {

	# cryptsetup isLuks "$dev" >/dev/null 2>&1
	# result=$?

	if [[ "$boot_dev" != "$root_dev" ]] && [ "$isLuksBoot" == false ] && [ "$isLuksRoot" == true ]; then

		cd / || return

		# set -euo pipefail
		sync
		umount -l /boot 2>/dev/null || true
		umount -l "$dev" 2>/dev/null || true

		mkdir -p /mnt/data_boot || true
		mount -o ro "$dev" /mnt/data_boot
		mkdir -p /data_boot || true
		rsync -aHAX --progress /mnt/data_boot/ /data_boot/
		umount -l /mnt/data_boot || true

		root_real=$(get_real_backing "$root_dev")

		echo -e "${GREEN} Action with device ${dev} ${NC}"
		cryptsetup luksFormat --uuid="$uuid_boot_locked" --hash=sha256 --key-size=512 --label=LinuxH --pbkdf=pbkdf2 --use-urandom "$dev"
		cryptsetup luksAddKey "$dev" /keys/key_luks2_tpm2_pcr/key.bin --pbkdf=pbkdf2

		echo -e "${GREEN} Action with device ${root_real} ${NC}"
		cryptsetup luksAddKey "$root_real" /keys/key_luks2_tpm2_pcr/key_root.bin

		systemd-cryptsetup attach my_crypt "$dev" /keys/key_luks2_tpm2_pcr/key.bin

		if [ "$fsType" == "xfs" ]; then
			mkfs.xfs -m uuid="$uuid_boot_unlocked" -L LinuxH /dev/mapper/my_crypt
		elif [ "$fsType" == "ext4" ]; then
			mkfs.ext4 -U "$uuid_boot_unlocked" -L LinuxH /dev/mapper/my_crypt
		fi

		sed -i "s/$uuid_old/$uuid_boot_unlocked/g" /etc/fstab
		if ! grep -q "luks-$uuid_boot_locked" /etc/crypttab; then
			echo "luks-$uuid_boot_locked UUID=$uuid_boot_locked /keys/key_luks2_tpm2_pcr/key.bin discard" >>/etc/crypttab
		fi

		mount -o rw /dev/mapper/my_crypt /boot
		rsync -aHAX --progress /data_boot/ /boot/
		# cp /home/$user_current/repos/one_time_file_enc_sha256/expected.sha256 /boot/expected.sha256
		# cp /home/$user_current/repos/one_time_file_enc_sha256/one_time_random.bin.enc /boot/one_time_random.bin.enc
		echo "add_dracutmodules+=\" fido2 \"" | tee /etc/dracut.conf.d/fido2.conf
		echo "add_dracutmodules+=\" tpm2-tss \"" | tee /etc/dracut.conf.d/tpm2.conf
		echo "install_items+=\" /keys/key_luks2_tpm2_pcr/key.bin \"" | tee /etc/dracut.conf.d/keys.conf

		if [ -f /keys/key_luks2_tpm2_pcr/key_root.bin ]; then
			uuid_root_real=$(blkid -s UUID -o value "$root_real")

			# in line contain root real uuid, if contain none, replace to /keys/key_luks2_tpm2_pcr/key_root.bin

			awk -v uuid="$uuid_root_real" -v key="/keys/key_luks2_tpm2_pcr/key_root.bin" '
				$0 ~ uuid {
    				if ($3 == "none") {
        				$3 = key
    				}
				}
				{print}
			' /etc/crypttab >/etc/crypttab.tmp && mv /etc/crypttab.tmp /etc/crypttab

			echo "install_items+=\" /keys/key_luks2_tpm2_pcr/key_root.bin \"" | tee /etc/dracut.conf.d/keys_root.conf
		fi

		dracut -f -v

		if [ "$os_id" == "fedora" ]; then
			cp "$REPO_DIR"/1_fedora /etc/grub.d
			sed -i "s/(os_version)/$os_version/g" /etc/grub.d/1_fedora
			sed -i "s/(os_name)/$os_id/g" /etc/grub.d/1_fedora
			sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/1_fedora
			sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/1_fedora
			sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/1_fedora
			chmod +x /etc/grub.d/1_fedora

		elif [ "$os_id" == "rhel" ]; then
			cp "$REPO_DIR"/69_redhat /etc/grub.d/
			sed -i "s/(os_version)/$os_version/g" /etc/grub.d/69_redhat
			sed -i "s/(os_name)/$os_id/g" /etc/grub.d/69_redhat
			sed -i "s/(boot_mapper_uuid)/$uuid_boot_unlocked/g" /etc/grub.d/69_redhat
			sed -i "s/(kernel_version)/$kernel_ver/g" /etc/grub.d/69_redhat
			sed -i "s/(kernel_parameters)/$escaped_kernel_para/g" /etc/grub.d/69_redhat
			chmod +x /etc/grub.d/69_redhat
		fi

		grub2-mkconfig -o /boot/grub2/grub.cfg
	fi
}

# main() {
# create_one_time_file_enc_sha256
create_keys_secureboot
create_luks2_boot_partition
grub2_bootloader_setup
pcr_oracle_tpm2_seal
# }

chown -R $user_current:$user_current /home/$user_current/repos
# main |& tee /result.txt
echo "Hoàn tất thiết lập phân vùng /boot mã hóa LUKS2 với TPM2 và Secure Boot!"

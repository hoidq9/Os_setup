#/bin/bash

source ../variables.sh

if [ "$EUID" -ne 0 ]; then
	echo -e "${RED}This script must be run as root.${NC}"
	exit 1
fi

dnf install pesign systemd-boot-unsigned -y

# set -euo pipefail
DAYS_VALID=3650 # 10 years expriry

# Nếu chưa có thư mục /keys/secureboot, tạo mới với quyền 700 ngay từ đầu
if [ ! -d /keys/secureboot ]; then
	mkdir -p /keys/secureboot
	chmod 700 /keys/secureboot
fi

cd /keys/secureboot || exit 1

NEED_NEW_CERT=false

# Nếu chưa có key hoặc cert → tạo mới
if [ ! -f "${os_id}-auth.key" ]; then
	NEED_NEW_CERT=true
else
	# Nếu có cert rồi, kiểm tra xem có hết hạn chưa (7 ngày trước hạn thì tái tạo)
	if ! openssl x509 -checkend $((7 * 24 * 3600)) -noout -in "${os_id}-auth.x509" >/dev/null 2>&1; then
		echo "→ Chứng chỉ đã hết hạn hoặc sắp hết hạn. Sẽ tạo mới."
		NEED_NEW_CERT=true
	fi
fi

# Nếu chưa có private .key, mới sinh
if [ "${NEED_NEW_CERT}" = true ]; then

	# ==== CẤU HÌNH CHUNG ====
	SUBJECT="/C=Vn/ST=Hanoi/L=Hanoi/O=VnH/OU=VnW/CN=${os_id}-auth.com"

	# 1. Tạo private key (RSA 4096 bit) và self-signed certificate (X.509, SHA-512)
	openssl req -x509 \
		-newkey rsa:4096 \
		-sha512 \
		-days "${DAYS_VALID}" \
		-nodes \
		-keyout "${os_id}-auth.key" \
		-out "${os_id}-auth.x509" \
		-subj "${SUBJECT}"

	# 2. Chuyển certificate PEM (.x509) sang DER (.der)
	openssl x509 \
		-in "${os_id}-auth.x509" \
		-outform DER \
		-out "${os_id}-auth.der"

	# 3. Chuyển từ DER trở lại PEM (.pem) – giống cert.pem
	openssl x509 \
		-in "${os_id}-auth.der" \
		-inform DER \
		-outform PEM \
		-out "${os_id}-auth.pem"

	# 4. Xuất một phần thông tin (để kiểm tra) nhưng chỉ hiển thị văn bản vài dòng đầu
	openssl rsa -in "${os_id}-auth.key" -noout -text | head -n 5 && echo "   …"
	openssl x509 -in "${os_id}-auth.x509" -noout -text | head -n 5 && echo "   …"
	openssl x509 -in "${os_id}-auth.der" -inform DER -noout -text | head -n 5 && echo "   …"

	# 5. Tạo thêm file PKCS#12 (.p12) chứa private key + certificate,
	#    không đặt passphrase (pass empty) để dễ import vào NSS DB
	openssl pkcs12 -export \
		-inkey "${os_id}-auth.key" \
		-in "${os_id}-auth.x509" \
		-out "${os_id}-auth.p12" \
		-name "${os_id}-auth" \
		-passout pass:

	cp "${os_id}-auth.key" "${os_id}-auth.priv"
	cp "${os_id}-auth.x509" "${os_id}-auth.crt"

	# 6. Thiết lập quyền hạn chặt chẽ cho private key và file .p12
	chmod 600 "${os_id}-auth.key" # chỉ owner có thể đọc/ghi private key
	chmod 600 "${os_id}-auth.p12" # chỉ owner có thể đọc/ghi file PKCS#12
	chmod 700 /keys/secureboot    # chỉ owner có thể vào thư mục

	# 7. Import vào NSS DB (nếu cần)
	if [ "$os_id" == "rhel" ] || [ "$os_id" == "fedora" ]; then
		dnf install pesign -y
		dnf upgrade -y pesign
		pk12util -d /etc/pki/pesign -i /keys/secureboot/"${os_id}-auth.p12" -W ""
	fi

	# 7. Thông báo các file đã sinh
	echo "Hoàn thành! Bạn đã có các file trong /keys/secureboot:"
	echo "  • ${os_id}-auth.key   (Private key, PEM, không mã hóa passphrase)"
	echo "  • ${os_id}-auth.x509  (Certificate, PEM X.509, SHA-512)"
	echo "  • ${os_id}-auth.der   (Certificate, DER X.509)"
	echo "  • ${os_id}-auth.pem   (Certificate PEM xuất từ DER)"
	echo "  • ${os_id}-auth.p12   (PKCS#12, chứa cả private key và certificate)"

	# mokutil --import /keys/secureboot/"${os_id}-auth.der"
fi

efi_path=$(bootctl --print-path)

bootctl install

cp ${efi_path}/EFI/systemd/systemd-bootx64.efi ${efi_path}/EFI/systemd/grubx64.efi
cp ${efi_path}/EFI/redhat/shimx64.efi ${efi_path}/EFI/systemd/systemd-bootx64.efi
cp ${efi_path}/EFI/redhat/mmx64.efi ${efi_path}/EFI/systemd/mmx64.efi

cd ${efi_path}/EFI/systemd || exit 1
pesign --in grubx64.efi --out grubx64_new.efi --certificate "${os_id}-auth" --sign --force
mv grubx64_new.efi grubx64.efi

cp $REPO_DIR/rhel.conf ${efi_path}/loader/entries/rhel.conf
cp $REPO_DIR/loader.conf ${efi_path}/loader/loader.conf

if [ ! -d /etc/kernel ]; then
	mkdir -p /etc/kernel
fi
cp $REPO_DIR/install.conf /etc/kernel/install.conf

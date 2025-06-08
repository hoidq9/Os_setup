#!/usr/bin/env bash
set -euo pipefail

# Nếu chưa có thư mục /keys, tạo mới với quyền 700 ngay từ đầu
if [ ! -d /keys ]; then
    mkdir -p /keys
    chmod 700 /keys
fi

cd /keys || exit 1

# Nếu chưa có private key rhel.key, mới sinh
if [ ! -f rhel.key ]; then

    # ==== CẤU HÌNH CHUNG ====
    DAYS_VALID=36500
    SUBJECT="/C=VN/ST=Hanoi/L=Hanoi/O=VNH/OU=IT/CN=rhel.com"
    BASE_NAME="rhel" # sẽ sinh: rhel.key, rhel.x509, rhel.der, rhel.pem, rhel.p12

    # 1. Tạo private key (RSA 4096 bit) và self-signed certificate (X.509, SHA-512)
    openssl req -x509 \
        -newkey rsa:4096 \
        -sha512 \
        -days "${DAYS_VALID}" \
        -nodes \
        -keyout "${BASE_NAME}.key" \
        -out "${BASE_NAME}.x509" \
        -subj "${SUBJECT}"

    # 2. Chuyển certificate PEM (rhel.x509) sang DER (rhel.der)
    openssl x509 \
        -in "${BASE_NAME}.x509" \
        -outform DER \
        -out "${BASE_NAME}.der"

    # 3. Chuyển từ DER trở lại PEM (rhel.pem) – giống cert.pem
    openssl x509 \
        -in "${BASE_NAME}.der" \
        -inform DER \
        -outform PEM \
        -out "${BASE_NAME}.pem"

    # 4. Xuất một phần thông tin (để kiểm tra) nhưng chỉ hiển thị văn bản vài dòng đầu
    openssl rsa -in "${BASE_NAME}.key" -noout -text | head -n 5 && echo "   …"
    openssl x509 -in "${BASE_NAME}.x509" -noout -text | head -n 5 && echo "   …"
    openssl x509 -in "${BASE_NAME}.der" -inform DER -noout -text | head -n 5 && echo "   …"

    # 5. Tạo thêm file PKCS#12 (rhel.p12) chứa private key + certificate,
    #    không đặt passphrase (pass empty) để dễ import vào NSS DB
    openssl pkcs12 -export \
        -inkey "${BASE_NAME}.key" \
        -in "${BASE_NAME}.x509" \
        -out "${BASE_NAME}.p12" \
        -name "${BASE_NAME}" \
        -passout pass:

    # 6. Thiết lập quyền hạn chặt chẽ cho private key và file .p12
    chmod 600 "${BASE_NAME}.key" # chỉ owner có thể đọc/ghi private key
    chmod 600 "${BASE_NAME}.p12" # chỉ owner có thể đọc/ghi file PKCS#12
    chmod 700 /keys              # chỉ owner có thể vào thư mục

    # 7. Import vào NSS DB (nếu cần)
    if [ $(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release) == "rhel" ]; then
        dnf install pesign -y
        dnf upgrade -y pesign
        pk12util -d /etc/pki/pesign -i /keys/"${BASE_NAME}.p12" -W ""
    fi

    # 7. Thông báo các file đã sinh
    echo "Hoàn thành! Bạn đã có các file trong /keys:"
    echo "  • ${BASE_NAME}.key   (Private key, PEM, không mã hóa passphrase)"
    echo "  • ${BASE_NAME}.x509  (Certificate, PEM X.509, SHA-512)"
    echo "  • ${BASE_NAME}.der   (Certificate, DER X.509)"
    echo "  • ${BASE_NAME}.pem   (Certificate PEM xuất từ DER)"
    echo "  • ${BASE_NAME}.p12   (PKCS#12, chứa cả private key và certificate)"

fi

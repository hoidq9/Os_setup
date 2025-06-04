#!/usr/bin/env bash
set -euo pipefail

if [ ! -d /keys ]; then
    mkdir -p /keys
fi

cd /keys || exit 1

if [ ! -f db.key ]; then

    # ==== CẤU HÌNH CHUNG ====
    DAYS_VALID=36500
    SUBJECT="/C=VN/ST=Hanoi/L=Hanoi/O=VNH/OU=IT/CN=vnh.com"
    BASE_NAME="db" # tên chung cho các file: db.key, db.x509, db.der, db.pem

    openssl req -x509 \
        -newkey rsa:4096 \
        -sha512 \
        -days "${DAYS_VALID}" \
        -nodes \
        -keyout "${BASE_NAME}.key" \
        -out "${BASE_NAME}.x509" \
        -subj "${SUBJECT}"

    openssl x509 \
        -in "${BASE_NAME}.x509" \
        -outform DER \
        -out "${BASE_NAME}.der"

    openssl x509 \
        -in "${BASE_NAME}.der" \
        -inform DER \
        -outform PEM \
        -out "${BASE_NAME}.pem"

    openssl rsa -in "${BASE_NAME}.key" -noout -text | head -n 5 && echo "   …"
    openssl x509 -in "${BASE_NAME}.x509" -noout -text | head -n 5 && echo "   …"
    openssl x509 -in "${BASE_NAME}.der" -inform DER -noout -text | head -n 5 && echo "   …"

    echo "Hoàn thành! Bạn đã có các file:"
    echo "  • ${BASE_NAME}.key   (Private key đã được mã hóa, PEM)"
    echo "  • ${BASE_NAME}.x509  (Certificate, PEM X.509, SHA-512)"
    echo "  • ${BASE_NAME}.der   (Certificate, DER X.509)"
    echo "  • ${BASE_NAME}.pem   (Certificate, PEM xuất từ DER)"

    chmod 600 "${BASE_NAME}.key"
    chmod 700 /keys

fi

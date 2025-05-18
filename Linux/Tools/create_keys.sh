#!/usr/bin/env bash
set -euo pipefail

# ==== CẤU HÌNH CHUNG ====
DAYS_VALID=36500
SUBJECT="/C=VN/ST=Hanoi/L=Hanoi/O=VNW/OU=IT/CN=vnh.com"
BASE_NAME="db"   # tên chung cho các file: secureboot.key, secureboot.x509, secureboot.der

# ==== 1. TẠO PRIVATE KEY VÀ SELF-SIGNED CERTIFICATE (.key + .x509) ====
echo "1. Tạo RSA 4096-bit private key và self-signed X.509 certificate (.key + .x509)..."
openssl req -x509 \
    -newkey rsa:4096 \
    -sha256 \
    -days "${DAYS_VALID}" \
    -nodes \
    -keyout "${BASE_NAME}.priv" \
    -out "${BASE_NAME}.x509" \
    -subj "${SUBJECT}"

    # -keyout "${BASE_NAME}.key"

# ==== 2. XUẤT CHỨNG CHỈ SANG DER (.der) ====
echo "2. Chuyển certificate PEM (.x509) sang DER (.der)..."
openssl x509 \
    -in "${BASE_NAME}.x509" \
    -outform DER \
    -out "${BASE_NAME}.der"

openssl x509 -in "${BASE_NAME}.der" -inform DER -outform PEM -out "${BASE_NAME}.pem"

# ==== 3. KIỂM TRA NỘI DUNG ====
echo "3. Kiểm tra nội dung file:"
echo "- Private key (PEM):"
openssl rsa -in "${BASE_NAME}.key" -noout -text | head -n 5 && echo "   …"
echo "- Certificate (PEM):"
openssl x509 -in "${BASE_NAME}.x509" -noout -text | head -n 5 && echo "   …"
echo "- Certificate (DER):"
openssl x509 -in "${BASE_NAME}.der" -inform DER -noout -text | head -n 5 && echo "   …"

echo "Hoàn thành! Bạn đã có:"
echo "  • ${BASE_NAME}.key   (Private key, PEM)"
echo "  • ${BASE_NAME}.x509  (Certificate, PEM X.509)"
echo "  • ${BASE_NAME}.der   (Certificate, DER X.509)"

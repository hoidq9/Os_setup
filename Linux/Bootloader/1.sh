#!/usr/bin/env bash
set -euo pipefail

if [ ! -f /keys/test_key/key ]; then
	mkdir -p /keys/test_key
	dd if=/dev/urandom of=/keys/test_key/key bs=32 count=3
	chmod 600 /keys/test_key/key
fi

KEYFILE=/keys/test_key/key
OUTDIR=/keys/test_key
mkdir -p "$OUTDIR"
PRIV="$OUTDIR/priv-ecdsa-nist-p256.pem"
CERT="$OUTDIR/cert-ecdsa-nist-p256.pem"
SIG="$OUTDIR/$(basename "$KEYFILE").sig"
PUB="$OUTDIR/pub-ecdsa-nist-p256.pem"
DER="$OUTDIR/cert-ecdsa-nist-p256.der"

if [ ! -f "$KEYFILE" ]; then
	echo "Keyfile not found: $KEYFILE" >&2
	exit 3
fi

openssl ecparam -name prime256v1 -genkey -noout -out "$PRIV"
openssl req -new -x509 -key "$PRIV" -out "$CERT" -days 365 -subj "/CN=ecdsa-keyfile-sign/"
openssl dgst -sha256 -sign "$PRIV" -out "$SIG" "$KEYFILE"
openssl x509 -in "$CERT" -pubkey -noout >"$PUB"
openssl x509 -in "$CERT" -inform PEM -outform DER -out "$DER"

echo "$PRIV"
echo "$CERT"
echo "$SIG"
echo "$PUB"

#!/usr/bin/env bash
set -euo pipefail
mkdir -p /NVIDIA

BASE_URL="https://download.nvidia.com/XFree86/Linux-x86_64/"

TMP_HTML=$(mktemp)
curl -s "$BASE_URL" -o "$TMP_HTML"
VERSIONS=$(grep -Eo '[0-9]+\.[0-9]+\.[0-9]+/' "$TMP_HTML" | sed 's:/$::')

if [[ -z "$VERSIONS" ]]; then
    rm -f "$TMP_HTML"
    exit 1
fi

LATEST_VERSION=$(printf "%s\n" $VERSIONS | sort -V | tail -n1)

# How to get the current version of the NVIDIA driver installed on the system
CURRENT_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "0.0.0")

if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    rm -rf "$TMP_HTML"
    exit 0
else
    rm -rf /NVIDIA/*
    cd /NVIDIA || exit 1
    RUN_FILE="NVIDIA-Linux-x86_64-${LATEST_VERSION}.run"
    DOWNLOAD_URL="${BASE_URL}${LATEST_VERSION}/${RUN_FILE}"

    if [[ ! -f "$RUN_FILE" ]]; then
        wget --continue --show-progress "$DOWNLOAD_URL" -O "$RUN_FILE"
    fi

    rm -f "$TMP_HTML"

    chmod +x "$RUN_FILE"

    bash "$RUN_FILE" -s --systemd --rebuild-initramfs --install-compat32-libs --dkms --allow-installation-with-running-driver --module-signing-secret-key=/keys/db.key --module-signing-public-key=/keys/db.x509 --no-x-check
fi

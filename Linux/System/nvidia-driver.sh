#!/bin/bash
mkdir -p /NVIDIA
device_id=$(lspci -nn | grep -i nvidia | grep VGA | sed 's/.*\[\([0-9a-fA-F:]\+\)\].*/\1/' | cut -d: -f2)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$device_id" ]; then
    echo "❌ Không tìm thấy card NVIDIA nào trên hệ thống." >&2
    exit 1
fi

# driver_version=$(curl -s https://www.nvidia.com/en-us/drivers/unix/ | sed -n '/<p[^>]*>.*Linux x86_64\/AMD64\/EM64T.*<\/p>/p' | grep -oP 'Latest Production Branch Version:</span>\s*<a [^>]+>[^<]+</a>' | grep -oP '<a [^>]+>[^<]+</a>' | grep -o "[0-9]\{3\}\.[0-9]\{3\}")

driver_version=$(
    curl -s https://www.nvidia.com/en-us/drivers/unix/ |
        grep "Latest Production Branch Version:" |
        grep "Linux x86_64/AMD64/EM64T" |
        grep -Pzo '(?s)<span[^>]*>Latest Production Branch Version:</span>.*?<a[^>]*>\K[^<]+' |
        tr -d '\0[:space:]'
)
curl -s https://download.nvidia.com/XFree86/Linux-x86_64/$driver_version/README/supportedchips.html -o $DIR/supportedchips.html

if grep -qoiw "$device_id" $DIR/supportedchips.html; then
    echo "✅ Card NVIDIA ($device_id) được hỗ trợ bởi driver $driver_version."

    CURRENT_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null || echo "0.0.0")
    BASE_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64"

    if [[ "$CURRENT_VERSION" < "$driver_version" ]]; then
        cd /NVIDIA || exit 1
        RUN_FILE="NVIDIA-Linux-x86_64-${driver_version}.run"
        DOWNLOAD_URL="${BASE_URL}/${driver_version}/${RUN_FILE}"

        if [[ ! -f "$RUN_FILE" ]]; then
            wget --continue --show-progress "$DOWNLOAD_URL" -O "$RUN_FILE"
        fi

        if rpm -q dkms; then
            dkms status | grep nvidia | awk '{print $1}' | while read module; do
                dkms remove -m "$module" --all
            done
        fi

        chmod +x "$RUN_FILE"
        mv "$RUN_FILE" nvidia-driver.run

    fi
else
    echo "❌ Card NVIDIA ($device_id) không được hỗ trợ bởi driver $driver_version."
    exit 1
fi

rm -rf $DIR/supportedchips.html

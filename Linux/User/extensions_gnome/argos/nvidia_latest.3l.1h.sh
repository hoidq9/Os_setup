#!/bin/bash

device_id=$(lspci -nn | grep -i nvidia | grep VGA | sed -n 's/.*\[\([0-9a-fA-F:]\+\)\].*/\1/p' | cut -d: -f2)

driver_version=$(
	curl -s https://www.nvidia.com/en-us/drivers/unix/ |
		grep "Latest Production Branch Version:" |
		grep "Linux x86_64/AMD64/EM64T" |
		grep -Pzo '(?s)<span[^>]*>Latest Production Branch Version:</span>.*?<a[^>]*>\K[^<]+' |
		tr -d '\0[:space:]'
)

BASE_URL="https://us.download.nvidia.com/XFree86/Linux-x86_64"
if command -v nvidia-smi >/dev/null 2>&1; then
	CURRENT_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader 2>/dev/null)
fi

verlte() { printf '%s\n%s\n' "$1" "$2" | sort -V -C; }

if [ -n "$device_id" ] && command -v nvidia-smi >/dev/null 2>&1; then
	if curl -s "$BASE_URL/$driver_version/README/supportedchips.html" | grep -qoiw "$device_id" && verlte "$driver_version" "$CURRENT_VERSION"; then
		nvidia_var=✅
	else
		nvidia_var=❌
	fi
else
	nvidia_var=?
fi

echo "NVIDIA: $nvidia_var"

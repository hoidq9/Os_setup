#!/usr/bin/env bash
set -euo pipefail

UKI_PATH=/boot/ukify-linux.efi

kver_uki=$(bootctl kernel-inspect "$UKI_PATH" | awk -F: '/Version:/ {gsub(/^[ \t]+/,"",$2); print $2; exit}')
kver_latest=$(ls -1 /lib/modules | sort -V | tail -n1)

if [ "$kver_uki" = "$kver_latest" ]; then
  echo " UKI: ✅ "
else
  echo " UKI: ❌ "
fi
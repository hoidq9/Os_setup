#!/usr/bin/env bash
set -euo pipefail
UKI_PATH=/boot/ukify-linux.efi

if [ ! -f "$UKI_PATH" ]; then
	uki_var=?
else
	kver_uki=$(bootctl kernel-inspect "$UKI_PATH" | awk -F: '/Version:/ {gsub(/^[ \t]+/,"",$2); print $2; exit}')
	kver_latest=$(ls -1 /lib/modules | sort -V | tail -n1)

	if [ "$kver_uki" = "$kver_latest" ]; then
		uki_var=Yes
	else
		uki_var=No
	fi
fi

grep -q "\[confidentiality\]" /sys/kernel/security/lockdown &&
	lockdown_var=Enabled || lockdown_var=Disabled

echo " UKI: $uki_var 		Lockdown: $lockdown_var "

#!/bin/bash

uki_exists=false
current_uki_found=false
path_uki_found=""

read_efi_string() {
	local var="$1"

	[[ -f "$var" ]] || return 1

	tail -c +5 "$var" 2>/dev/null |
		iconv -f UTF-16LE -t UTF-8 2>/dev/null |
		tr -d '\0'
}

normalize_efi_path() {
	local path="$1"

	path="${path//\\//}"
	path="${path#/}"
	path="${path%/}"

	printf '%s\n' "${path,,}"
}

stub_var=$(
	find /sys/firmware/efi/efivars \
		-maxdepth 1 \
		-type f \
		-name 'StubImageIdentifier-*' \
		-print -quit 2>/dev/null
)

if [[ -n "$stub_var" ]]; then
	current_efi_path=$(read_efi_string "$stub_var")
else
	current_efi_path=""
fi

stub_uuid_var=$(
	find /sys/firmware/efi/efivars \
		-maxdepth 1 \
		-type f \
		-name 'StubDevicePartUUID-*' \
		-print -quit 2>/dev/null
)

if [[ -n "$stub_uuid_var" ]]; then
	current_partuuid=$(read_efi_string "$stub_uuid_var")
else
	current_partuuid=""
fi

current_efi_path=$(normalize_efi_path "$current_efi_path")
current_partuuid="${current_partuuid,,}"

while IFS= read -r -d '' file; do
	sections=$(objdump -h "$file" 2>/dev/null) || continue

	objdump -f "$file" 2>/dev/null |
		grep -q 'pei-' || continue

	grep -qE '^[[:space:]]*[0-9]+[[:space:]]+\.linux[[:space:]]' \
		<<<"$sections" || continue

	uki_exists=true

	mountpoint=$(findmnt -T "$file" -no TARGET 2>/dev/null) || continue
	partuuid=$(findmnt -T "$file" -no PARTUUID 2>/dev/null) || continue

	relative_path=$(
		realpath --relative-to="$mountpoint" "$file" 2>/dev/null
	) || continue

	file_efi_path=$(normalize_efi_path "$relative_path")

	if [[ -n "$current_efi_path" &&
		-n "$current_partuuid" &&
		"${partuuid,,}" == "$current_partuuid" &&
		"$file_efi_path" == "$current_efi_path" ]]; then

		path_uki_found="$file"
		current_uki_found=true

	fi

done < <(
	find /boot /boot/efi /efi \
		-type f \
		-name '*.efi' \
		-print0 2>/dev/null |
		sort -z -u
)

case $1 in
--print-path-UKI)
	echo "$path_uki_found"
	;;
--print-is-booting)
	if $current_uki_found == true; then
		echo "true"
	else
		echo "false"
	fi
	;;
*)
	printf '%s\n' "[UKI_Booting] $path_uki_found"
	;;
esac

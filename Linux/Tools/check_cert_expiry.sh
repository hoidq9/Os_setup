#!/bin/bash
user_current=$(logname)
os_id=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)

openssl x509 -inform DER -in /boot/"${os_id}-${user_current}.der" -checkend 31536000 >/dev/null
res=$?
if [ $res -eq 0 ]; then
	A="OK"
else
	A="Failed"
fi

if [[ $(openssl x509 -inform DER -noout -modulus -in /boot/"${os_id}-${user_current}.der" | openssl md5) == $(cat /keys/private.key.md5) ]]; then
	B="OK"
else
	B="Failed"
fi

if [ "$A" = "OK" ] && [ "$B" = "OK" ]; then
	echo " DER: ✅ "
else
	echo " DER: ❌ "
fi

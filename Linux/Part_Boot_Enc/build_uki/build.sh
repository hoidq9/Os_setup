#!/bin/bash

REPO_DIR="$(dirname "$(readlink -m "${0}")")"
RED='\033[0;31m'
NC='\033[0m' # No Color
user_current=$(logname)
os_id=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release)
latest_kernel=$(rpm -q kernel --qf "%{VERSION}-%{RELEASE}.%{ARCH}\n" | sort -V | tail -n1)
parameters=$(dracut --fstab --print-cmdline)

if [ "$EUID" -ne 0 ]; then
	echo -e "${RED}This script must be run as root.${NC}"
	exit 1
fi

./create_keys_secureboot.sh

if [ ! -f /etc/systemd/tpm2-pcr-private-key.pem ]; then
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /etc/systemd/tpm2-pcr-private-key.pem
	openssl rsa -pubout -in /etc/systemd/tpm2-pcr-private-key.pem -out /etc/systemd/tpm2-pcr-public-key.pem
fi

dnf install systemd-ukify -y &>/dev/null 2>&1

vmlinuz_path="/usr/lib/modules/${latest_kernel}/vmlinuz"
initramfs_path="/boot/initramfs-${latest_kernel}.img"
cmdline_path="${parameters} rhgb lockdown=confidentiality"
private_key_path="/keys/secureboot/${os_id}-${user_current}.key"
certificate_path="/keys/secureboot/${os_id}-${user_current}.x509"

cp uki.cfg setup.cfg
sed -i "s|(vmlinuz)|${vmlinuz_path}|g" setup.cfg
sed -i "s|(initramfs)|${initramfs_path}|g" setup.cfg
sed -i "s|(cmdline)|${cmdline_path}|g" setup.cfg
sed -i "s|(private-key)|${private_key_path}|g" setup.cfg
sed -i "s|(certificate)|${certificate_path}|g" setup.cfg

ukify build --config=${REPO_DIR}/setup.cfg --output /boot/ukify-linux.efi
rm -rf $REPO_DIR/setup.cfg

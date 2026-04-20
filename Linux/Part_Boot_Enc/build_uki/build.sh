#!/bin/bash

REPO_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
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

if [ ! -f /keys/secureboot/tpm2-pcr-private-key.pem ]; then
	openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:4096 -out /keys/secureboot/tpm2-pcr-private-key.pem
	openssl rsa -pubout -in /keys/secureboot/tpm2-pcr-private-key.pem -out /etc/systemd/tpm2-pcr-public-key.pem
fi

dnf install systemd-ukify -y # /&>/dev/null 2>&1

vmlinuz_path="/usr/lib/modules/${latest_kernel}/vmlinuz"
initramfs_path="/boot/initramfs-${latest_kernel}.img"
cmdline_path="${parameters} rhgb lockdown=confidentiality intel_iommu=on efi=disable_early_pci_dma module.sig_enforce=1 slab_nomerge page_alloc.shuffle=1 pti=on spectre_v2=on spec_store_bypass_disable=on vsyscall=none randomize_kstack_offset=on random.trust_cpu=off rd.systemd.show_status=1 loglevel=7 plymouth.enable=1 rd.plymouth=1 init_on_alloc=1 init_on_free=1 audit=1 crashkernel=512M nosmt=1"

private_key_path="/keys/secureboot/${os_id}-${user_current}.key"
certificate_path="/keys/secureboot/${os_id}-${user_current}.x509"

cp uki.cfg setup.cfg
sed -i "s|(vmlinuz)|${vmlinuz_path}|g" setup.cfg
sed -i "s|(initramfs)|${initramfs_path}|g" setup.cfg
sed -i "s|(cmdline)|${cmdline_path}|g" setup.cfg
sed -i "s|(private-key)|${private_key_path}|g" setup.cfg
sed -i "s|(certificate)|${certificate_path}|g" setup.cfg
[[ "$(plymouth-set-default-theme)" != "details" ]] && plymouth-set-default-theme details -R || echo "Not changed."

dracut -f -v --regenerate-all
ukify build --config=${REPO_DIR}/setup.cfg --output /boot/ukify-linux.efi
rm -rf $REPO_DIR/setup.cfg

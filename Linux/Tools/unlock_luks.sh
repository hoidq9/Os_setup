#!/bin/bash
source ../variables.sh

# Mã màu
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Không màu

# Kiểm tra quyền root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script must be run as root.${NC}"
    exit 1
fi

echo

# Kiểm tra các phân vùng được mã hóa bằng LUKS
encrypted_partitions=()
echo -e "${BLUE}--- Scanning for LUKS encrypted partitions... ---${NC}"

while read -r line; do
    # Trích xuất đường dẫn thiết bị từ đầu dòng
    partition=$(echo "$line" | awk -F: '{print $1}')
    encrypted_partitions+=("$partition")
done < <(blkid | grep "crypto_LUKS")

# Hiển thị kết quả
if [[ ${#encrypted_partitions[@]} -gt 0 ]]; then
    echo -e "${GREEN}Các phân vùng được mã hóa LUKS:${NC}"
    for partition in "${encrypted_partitions[@]}"; do
        echo -e "${YELLOW}  - $partition${NC}"
    done
else
    echo -e "${RED}Không tìm thấy phân vùng mã hóa LUKS.${NC}"
    exit 0
fi

# Thêm một dòng trống để cách biệt
echo ""

# Hiển thị thông tin FIDO2 và YubiKey
echo -e "${BLUE}--- Listing FIDO2 devices and TPM2 devices... ---${NC}"
echo -e "${GREEN}"
systemd-cryptenroll --fido2-device=list
echo -e "${RED}"
systemd-cryptenroll --tpm2-device=list

echo ""

echo -ne "${YELLOW}Do you want to enroll a new FIDO2 device to unlock LUKS2? (y/n): ${NC}"
read -r enroll_fido2

if [[ "$enroll_fido2" == "y" ]]; then

    if [ "$os_id" == "rhel" ]; then
        bash $REPO_DIR/edit_crypttab.sh
    fi

    echo -ne "${YELLOW}Type the path to the FIDO2 device (Enter correctly, not contain spaces) (ex: /dev/hidraw?): ${NC}"
    read -r fido2_device_path
    echo -ne "${YELLOW}Type the disk path of the LUKS2 partition (Enter correctly, not contain spaces) (ex: /dev/nvme0n1p?): ${NC}"
    read -r luks2_disk_path
    echo "add_dracutmodules+=\" fido2 \"" | sudo tee /etc/dracut.conf.d/fido2.conf
    systemd-cryptenroll --fido2-device=$fido2_device_path --fido2-with-client-pin=no --fido2-with-user-verification=yes --fido2-with-user-presence=yes $luks2_disk_path
    dracut -f
    echo -e "${GREEN}FIDO2 device enrolled successfully.${NC}"
fi

echo

echo -ne "${YELLOW}Do you want to enroll a new TPM2 device to unlock LUKS2? (y/n): ${NC}"
read -r enroll_tpm2

if [[ "$enroll_tpm2" == "y" ]]; then
    echo -ne "${YELLOW}Type the path to the TPM2 device (Enter correctly, not contain spaces) (ex: /dev/tpm0): ${NC}"
    read -r tpm2_device_path
    echo -ne "${YELLOW}Type the disk path of the LUKS2 partition (Enter correctly, not contain spaces) (ex: /dev/nvme0n1p?): ${NC}"
    read -r luks2_disk_path
    echo "add_dracutmodules+=\" tpm2-tss \"" | sudo tee /etc/dracut.conf.d/tpm2.conf
    systemd-cryptenroll --wipe-slot=tpm2 $luks2_disk_path
    if systemd-detect-virt | grep -q "none"; then
        systemd-cryptenroll --tpm2-device=$tpm2_device_path --tpm2-pcrs "0+7" $luks2_disk_path # --tpm2-with-pin=yes
    else
        systemd-cryptenroll --tpm2-device=$tpm2_device_path --tpm2-pcrs "7" $luks2_disk_path
    fi
    dracut -f
    echo -e "${GREEN}TPM2 device enrolled successfully.${NC}"
fi

dnf autoremove -y &>/dev/null

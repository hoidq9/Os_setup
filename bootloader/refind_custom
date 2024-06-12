#!/bin/bash

dnf upgrade -y

rm -rf /boot/efi/EFI/refind /etc/refind.d /boot/refind_linux.conf
mkdir -p refind_custom_folder
cd refind_custom_folder
wget https://sourceforge.net/projects/refind/files/latest/download\?source\=files -O refind.zip

zip_file="refind.zip"
destination_dir="."

# Giải nén file ZIP
unzip -q "$zip_file" -d "$destination_dir"

# Lấy tên thư mục mới tạo
new_dir=$(unzip -l "$zip_file" | awk 'NR>3 {print $4}' | grep -o '^[^/]*' | sort -u | head -n 1)

cd $new_dir

./refind-install --shim /boot/efi/EFI/redhat/shimx64.efi --keepname --yes

cd ../..

rm -rf refind_custom_folder

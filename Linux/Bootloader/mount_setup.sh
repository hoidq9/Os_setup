#!/bin/bash

set -euo pipefail
umount -l /boot 2>/dev/null || true

echo "Đọc /etc/fstab để tìm mục /boot và /boot/efi..."
# Lấy các dòng không comment và có mountpoint là /boot hoặc /boot/efi
mapfile -t lines < <(awk '!/^#/ && ($2=="/boot" || $2=="/boot/efi") {print $1 " " $2}' /etc/fstab)
if [ ${#lines[@]} -eq 0 ]; then
    echo "Không tìm thấy mục /boot hoặc /boot/efi trong /etc/fstab."
    exit 0
fi

for entry in "${lines[@]}"; do
    deviceSpec="${entry%% *}"
    mountpoint="${entry##* }"
    echo "Dòng fstab: device=\"$deviceSpec\", mountpoint=\"$mountpoint\""

    # Xác định thư mục mount đích tạm
    if [ "$mountpoint" = "/boot" ]; then
        target="/boot"
    elif [ "$mountpoint" = "/boot/efi" ]; then
        target="/boot/efi"
    fi
    echo "Chuẩn bị mount point tại $target"
    mkdir -p "$target"

    # Xác định thiết bị vật lý dựa vào UUID hoặc PARTUUID
    if [[ "$deviceSpec" == UUID=* ]]; then
        uuid="${deviceSpec#UUID=}"
        dev=$(readlink -f "/dev/disk/by-uuid/$uuid" 2>/dev/null || true)
    elif [[ "$deviceSpec" == PARTUUID=* ]]; then
        partuuid="${deviceSpec#PARTUUID=}"
        dev=$(readlink -f "/dev/disk/by-partuuid/$partuuid" 2>/dev/null || true)
    else
        dev="$deviceSpec"
    fi

    # Kiểm tra thiết bị
    if [ -z "${dev:-}" ] || [ ! -b "$dev" ]; then
        echo "Lỗi: Không tìm thấy block device cho '$deviceSpec'."
        continue
    fi
    echo "Thiết bị tìm được: $dev"

    # Kiểm tra xem đã mount chưa
    if findmnt --source "$dev" >/dev/null; then
        current=$(findmnt -n -o TARGET --source "$dev")
        umount -l "$current" || true
    fi

    # Xác định fstype để chọn options
    fstype=$(blkid -o value -s TYPE "$dev" || echo "")
    mount_opts=""
    if [ "$fstype" = "vfat" ]; then
        # EFI partition: root RW, user chỉ đọc
        mount_opts="rw,uid=0,gid=0,fmask=077,dmask=077"
    else
        # ext4/xfs: preserve unix perms, root có write, user theo file perms
        mount_opts="rw"
    fi

    mount -o "$mount_opts" "$dev" "$target"
done

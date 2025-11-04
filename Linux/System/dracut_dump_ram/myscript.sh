#!/bin/sh

# Script chạy tại pre-pivot, sau khi /sysroot được mount (root thật).
# Ví dụ: Tạo một file trong /etc của root thật và ghi log.

# Kiểm tra và remount /sysroot rw nếu cần
if ! mount | grep -q "/sysroot.*rw"; then
	if mount -o remount,rw /sysroot; then
		echo "Remounted /sysroot to rw successfully."
	else
		echo "Failed to remount /sysroot to rw. Exiting without changes." >/tmp/script_remount_error.log
		exit 1 # Không làm gián đoạn boot, nhưng log lỗi
	fi
fi

tpm2_pcrread >/sysroot/etc/hello.txt
# echo "Script tùy chỉnh chạy thành công sau khi mở khóa LUKS2!" >/sysroot/etc/custom-script-log.txt
# mkdir -p /sysroot/Extract-MasterKey-LUKS2
# cp /masterkey-luks2-initrd.service /sysroot/etc/systemd/system/masterkey-luks2-initrd.service
# cp /masterkey-luks2-initrd.sh /sysroot/Extract-MasterKey-LUKS2/masterkey-luks2-initrd.sh
# cp /1.py /sysroot/Extract-MasterKey-LUKS2/1.py
# ln -s /sysroot/etc/systemd/system/masterkey-luks2-initrd.service /sysroot/etc/systemd/system/multi-user.target.wants/masterkey-luks2-initrd.service

# Hoặc chạy lệnh phức tạp hơn, ví dụ: copy file hoặc chỉnh sửa config.
# cp /some/file /sysroot/path/to/dest

# Tùy chọn: Remount lại read-only để bảo mật (không bắt buộc, nhưng tốt hơn).
mount -o remount,ro /sysroot

# Đảm bảo exit 0 để không làm gián đoạn boot.
exit 0

#!/bin/bash

# Hàm check: Kiểm tra xem module có nên được include không. Trả về 0 để luôn include.
check() {
	return 0
}

# Hàm depends: Các module phụ thuộc (ví dụ: base và crypt cho LUKS2).
depends() {
	echo "base crypt"
}

# Hàm install: Cài đặt script vào hook pre-pivot.
install() {
	# Cài đặt script myscript.sh vào hook pre-pivot với ưu tiên 99 (chạy muộn).
	inst_hook pre-pivot 99 "$moddir/myscript.sh"
	# inst_simple "$moddir/masterkey-luks2-initrd.service" "/masterkey-luks2-initrd.service"
	# inst_simple "$moddir/masterkey-luks2-initrd.sh" "/masterkey-luks2-initrd.sh"
	# inst_simple "$moddir/1.py" "/1.py"
}

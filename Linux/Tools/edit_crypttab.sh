#!/usr/bin/env bash
set -e

# 1) Backup
# sudo cp /etc/crypttab /etc/crypttab.bak.$(date +%F_%T)

# 2) Kiểm tra xem có dòng nào chứa 'luks' nhưng chưa có 'fido2-device=auto' không
grep -E 'luks' /etc/crypttab | grep -qv 'fido2-device=auto'
if ! grep -E 'luks' /etc/crypttab | grep -qv 'fido2-device=auto'; then
    echo "Tất cả các dòng chứa 'luks' đã có 'fido2-device=auto'. Không thay đổi gì."
    exit 0
fi

# 3) Dùng awk để thêm fido2 cho các dòng cần
awk 'BEGIN {
    FS = "[ \t]+"
    OFS = "\t"
}
# Bỏ qua comment
/^#/ { print; next }

# Nếu dòng không có luks, in y nguyên
{
    if ($0 !~ /luks/) {
        print
        next
    }

    # Dòng có luks nhưng chưa có fido2
    if ($4 !~ /fido2-device=auto/) {
        if (NF < 4) {
            $4 = "fido2-device=auto"
        } else {
            $4 = $4 ",fido2-device=auto"
        }
    }
    print
}' /etc/crypttab >/etc/crypttab.new

# 4) Ghi đè file gốc
mv /etc/crypttab.new /etc/crypttab

echo "Đã thêm 'fido2-device=auto' cho các dòng chứa 'luks' (nếu cần)."

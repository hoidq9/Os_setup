#!/bin/bash

FILE=/etc/pam.d/gdm-password
PATTERN='pam_gnome_keyring.so use_authtok'

# Kiểm xem pattern có trong file không
if grep -q -E "${PATTERN}" "${FILE}"; then
  echo "Comment dòng chứa '${PATTERN}'…"

  # Thực hiện comment idempotent, giữ backup
  sudo sed -i.bak -E "/${PATTERN}/ s@^[[:space:]]*#*@#@" "${FILE}"

  echo "Hoàn tất. Backup lưu tại ${FILE}.bak"
else
  echo "Không tìm thấy '${PATTERN}' trong ${FILE}"
fi

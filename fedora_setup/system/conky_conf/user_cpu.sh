#!/bin/bash
s1=$(awk '/^cpu / {for (i=2; i<=8; i++) sum+=$i; print sum}' /proc/stat)
u1=$(awk '/^cpu / {print $2}' /proc/stat)
sleep 1
s2=$(awk '/^cpu / {for (i=2; i<=8; i++) sum+=$i; print sum}' /proc/stat)
u2=$(awk '/^cpu / {print $2}' /proc/stat)
# Tính sự thay đổi cho user và tổng thời gian
du=$((u2 - u1))
dt=$((s2 - s1))
# Tính phần trăm sử dụng CPU cho user
user=$(awk "BEGIN {printf \"%.1f\", ($du*100/$dt)}")
# In kết quả
echo "$user %"

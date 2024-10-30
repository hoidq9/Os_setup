#!/bin/bash
cpu=${1:-"cpu"} # Đối số 1: Số CPU (core); nếu bỏ trống sẽ mặc định là "cpu" (tính cho toàn bộ CPU)
metric=$2       # Đối số 2: Loại sử dụng ('system', 'user', 'idle')
# Xác định cột tương ứng cho mỗi loại sử dụng
case $metric in
"user") column=2 ;;
"nice") column=3 ;;
"system") column=4 ;;
"idle") column=5 ;;
"iowait") column=6 ;;
"irq") column=7 ;;
"softirq") column=8 ;;
*)
    echo "Sử dụng: $0 [cpu] <metric>"
    echo "metric: user, nice, system, idle, iowait, irq, softirq"
    exit 1
    ;;
esac

# Lấy giá trị ban đầu cho metric và tổng
s1=$(awk -v cpu="$cpu" '$1 == cpu {for (i=2; i<=8; i++) sum+=$i; print sum}' /proc/stat)
m1=$(awk -v cpu="$cpu" -v col=$column '$1 == cpu {print $col}' /proc/stat)

# Chờ 1 giây
sleep 1

# Lấy giá trị mới cho metric và tổng
s2=$(awk -v cpu="$cpu" '$1 == cpu {for (i=2; i<=8; i++) sum+=$i; print sum}' /proc/stat)
m2=$(awk -v cpu="$cpu" -v col=$column '$1 == cpu {print $col}' /proc/stat)

# Tính sự thay đổi và phần trăm sử dụng
dm=$((m2 - m1))
dt=$((s2 - s1))
usage=$(awk "BEGIN {printf \"%.1f\", ($dm*100/$dt)}")

# In kết quả
echo "$usage %"

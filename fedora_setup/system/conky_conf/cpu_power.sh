#!/bin/bash
while true; do
    time=0.3
    sum_1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    sleep $time
    sum_2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    res=$(echo "scale=1; (($sum_2 - $sum_1) / 1000000) / $time" | bc -l)
    if (( $(echo "$res < 10" | bc -l) )); then
        printf "%.3f\n" "$res" >/Os_H/cpu_power.txt
    elif (( $(echo "$res >= 10 && $res < 100" | bc -l) )); then
        printf "%.2f\n" "$res" >/Os_H/cpu_power.txt
    else
        printf "%.1f\n" "$res" >/Os_H/cpu_power.txt
    fi
    echo $(dmidecode -t memory | grep "Manufacturer:" | sort | uniq | awk '{print $2" "$3}') >/Os_H/ram_manufacturer.txt
done

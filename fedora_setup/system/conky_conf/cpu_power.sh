#!/bin/bash
while true; do
    time=0.3
    sum_1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    sleep $time
    sum_2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    res=$(echo "scale=1; (($sum_2 - $sum_1) / 1000000) / $time" | bc -l)
    echo "$res" >/cpuH/cpu_power.txt
    echo $(dmidecode -t memory | grep "Manufacturer:" | sort | uniq) >/cpuH/ram_manufacturer.txt
done

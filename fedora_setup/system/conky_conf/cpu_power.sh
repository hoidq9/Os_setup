#!/bin/bash
while true; do
    time=1
    sum_1=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    sleep $time
    sum_2=$(cat /sys/class/powercap/intel-rapl:0/energy_uj | awk 'BEGIN { sum = 0; } { sum += $1; } END { print sum; }')
    res=$(echo "scale=1; (($sum_2 - $sum_1) / 1000000) / $time" | bc -l)
    echo "$res" >$_HOME/Prj/conky_conf/cpu_power.txt
done

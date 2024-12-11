#!/bin/bash
while true; do
    echo $(sudo rdmsr 0x198 -u --bitfield 47:32 | awk '{printf "%.1f", $1/8192}') >/Os_H/cpu_voltage.txt
    sleep 0.3
done

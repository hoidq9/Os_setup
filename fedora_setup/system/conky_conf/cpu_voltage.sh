#!/bin/bash
while true; do
    echo $(sudo rdmsr 0x198 -u --bitfield 47:32 | awk '{printf "%.1f", $1/8192}') >$_HOME/Prj/conky_conf/cpu_voltage.txt
    sleep 1
done

#!/bin/bash

for dir in /sys/class/thermal/*; do if [ -f "$dir/type" ] && [ "$(cat "$dir/type")" = "x86_pkg_temp" ]; then
	cpu_temp=$(cat "$dir/temp")
	cpu_temp_max=$((cpu_temp / 1000))
fi; done

acpi_temp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))

voltage=$(cat /Os_H/cpu_voltage.txt)
power=$(cat /Os_H/cpu_power.txt)

echo " ⚡ $voltage V  🔌 $power W  🧠 $cpu_temp_max°C  🔥 $acpi_temp°C "

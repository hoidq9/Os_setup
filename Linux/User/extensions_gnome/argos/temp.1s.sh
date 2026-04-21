#!/bin/bash
for dir in /sys/class/thermal/thermal_zone*; do
	if [ -f "$dir/type" ] && [ "$(cat "$dir/type")" = "x86_pkg_temp" ]; then
		temp_raw=$(cat "$dir/temp")
		temp=$((temp_raw / 1000))

		# Nếu trên 80 độ thì hiện màu đỏ
		if [ $temp -gt 80 ]; then
			echo " ${temp}°C | color=red"
		else
			echo " ${temp}°C | color=green"
		fi
	fi
done

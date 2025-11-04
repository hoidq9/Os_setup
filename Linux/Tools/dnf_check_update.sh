#!/bin/bash
set -euo pipefail

dnf check-update --refresh >/dev/null 2>&1
status=$?

if [ $status -eq 100 ]; then
	echo " Run ./run.sh in Os_setup "
fi

if [ $status -eq 0 ]; then
	echo " System is up to date "
fi

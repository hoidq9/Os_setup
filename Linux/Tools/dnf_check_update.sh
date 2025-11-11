#!/bin/bash
set -euo pipefail

if dnf check-update --refresh >/dev/null 2>&1; then
    echo " System is up to date "
else
    status=$?
    if [ $status -eq 100 ]; then
        echo " Run ./run.sh in Os_setup "
    else
        echo " Error: dnf returned status $status"
    fi
fi

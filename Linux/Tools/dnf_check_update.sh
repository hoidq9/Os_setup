#!/bin/bash
set -euo pipefail

if dnf check-update --refresh >/dev/null 2>&1; then
    echo " Up to date "
else
    status=$?
    if [ $status -eq 100 ]; then
        echo " Run ./run.sh "
    else
        echo " Error status $status "
    fi
fi

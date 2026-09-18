#!/bin/bash
set -euo pipefail

if dnf check-update --best --exclude=gpsd,gpsd-libs --refresh >/dev/null 2>&1; then
	updateStatus=Yes
else
	updateStatus=No
fi

echo " Latest: $updateStatus "

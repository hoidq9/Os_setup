#!/bin/bash

set -euo pipefail

if dnf check-update --refresh >/dev/null 2>&1; then
	updateStatus=✅
else
	updateStatus=❌
fi

echo " Latest: $updateStatus "

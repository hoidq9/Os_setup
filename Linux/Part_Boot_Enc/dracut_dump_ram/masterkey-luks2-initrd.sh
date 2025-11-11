#!/bin/bash
cd /Extract-MasterKey-LUKS2
dnf debuginfo-install kernel-$(uname -r) -y
drgn 1.py dm-0 > output.txt 2>&1

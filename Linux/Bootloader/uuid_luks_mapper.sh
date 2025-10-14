#!/bin/bash
bootloader=$(lsblk -no MOUNTPOINT,PATH | awk '$1=="/boot/efi"{print $2}')
kerneldev=$(findmnt -n -o SOURCE /boot)
if cryptsetup isLuks "$kerneldev" 2>/dev/null; then
	mapperdev=$(lsblk -no NAME,PKNAME | awk -v d="${kerneldev##*/}" '$2==d{print "/dev/mapper/"$1; exit}')
fi

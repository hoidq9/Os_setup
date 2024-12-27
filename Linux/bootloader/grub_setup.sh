#!/bin/bash

if blkid | grep -q "btrfs"; then
    # Prepare
    mkdir -p grub_efi
    dnf upgrade -y

    # Extract
    cd grub_efi
    dnf download --downloadonly grub2-efi
    rpm_grub_efi=$(ls grub2-efi*.rpm)
    rpm2cpio $rpm_grub_efi | cpio -idmv

    # Environment variables
    EFI_FILE="$(pwd)/boot/efi/EFI/redhat/grubx64.efi"
    SBAT_SECTION="sbat.txt"
    OUTPUT_FILE="sbat.csv"

    # Package dependencies
    dnf install grub2-efi-x64-modules -y
    wget $(curl -s https://api.github.com/repos/kdave/btrfs-progs/releases/latest | grep browser_download_url | grep btrfs.static | cut -d '"' -f 4) -O btrfs
    mv btrfs /bin
    chmod +x /bin/btrfs

    # Extract the .sbat section from the EFI file
    objcopy --dump-section .sbat=$SBAT_SECTION $EFI_FILE

    # Read the SBAT data from the section file and append to CSV
    while IFS=',' read -r component_name component_generation vendor_name vendor_package_name vendor_version vendor_url; do
        echo "$component_name,$component_generation,$vendor_name,$vendor_package_name,$vendor_version,$vendor_url" >>$OUTPUT_FILE
    done <$SBAT_SECTION

    # Create EFI images
    grub2-mkimage -d /usr/lib/grub/x86_64-efi -p '' -o grubx64.efi -O x86_64-efi -c ../config.cfg -s $OUTPUT_FILE at_keyboard boot keylayouts usbserial_common usb serial usbserial_usbdebug usbserial_ftdi usbserial_pl2303 tpm chain efinet net backtrace connectefi lsefimmap lsefi efifwsetup efi_netfs zstd xfs fshelp version tftp test syslinuxcfg normal extcmd sleep terminfo search search_fs_uuid search_fs_file search_label regexp reboot png bitmap bufio pgp gcry_sha1 mpi pkcs1_v15 crypto password_pbkdf2 pbkdf2 gcry_sha512 part_gpt part_msdos part_apple minicmd mdraid1x diskfilter mdraid09 luks2 afsplitter cryptodisk json luks lvm linux loopback jpeg iso9660 increment http halt acpi mmap gzio gcry_crc gfxmenu video font gfxterm bitmap_scale trig video_colors gcry_whirlpool gcry_twofish gcry_sha256 gcry_serpent gcry_rsa gcry_rijndael fat f2fs ext2 echo procfs archelp configfile cat blscfg loadenv disk gettext datetime terminal priority_queue all_video video_bochs video_cirrus efi_uga efi_gop video_fb probe btrfs afs bfs hfs zfs multiboot multiboot2 ls lsmmap ntfs smbios loadbios
    mv grubx64.efi /boot/efi/EFI/redhat/
    cd /boot/grub2/themes/bootloader
    rm -rf 30_uefi-firmware bootloader.sh config.cfg grub_custom refind_custom
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

    # Clean
    cd $1
    rm -rf grub_efi /bin/btrfs
    dnf autoremove grub2-efi-x64-modules -y

else
    dnf reinstall grub2-efi -y
    grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
fi

sudo dnf install git -y
if [ -d grub2/.git ]; then
	cd grub2
	git pull
else
	git clone -b master https://github.com/rhboot/grub2.git
	cd grub2
fi
mkdir -p $(pwd)/../Grub
sudo dnf install -y https://zfsonlinux.org/fedora/zfs-release-2-8$(rpm --eval "%{dist}").noarch.rpm
sudo dnf install autoconf automake autopoint dejavu-sans-fonts dejavu-serif-fonts dejavu-sans-mono-fonts ranlib fuse3 fuse3-devel libzfs6-devel libtasn1-devel device-mapper-devel unifont unifont-fonts make patch freetype-devel kernel-devel -y
./bootstrap
./autogen.sh
./configure --prefix="$(pwd)/../Grub" --with-platform=efi --target=x86_64 --enable-stack-protector --enable-mm-debug --enable-cache-stats --enable-boot-time --enable-grub-emu-sdl2 --enable-grub-emu-sdl --enable-grub-emu-pci --enable-grub-mkfont --enable-grub-themes --enable-grub-mount --enable-device-mapper --enable-liblzma --enable-libzfs --enable-grub-protect --with-gnu-ld --with-unifont=/usr/share/fonts/unifont/unifont.otf

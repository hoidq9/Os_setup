#!/bin/bash

mkdir -p /usr/lib/dracut/modules.d/99custom
sudo cp module-setup.sh /usr/lib/dracut/modules.d/99custom/
sudo cp myscript.sh /usr/lib/dracut/modules.d/99custom/
sudo cp masterkey-luks2-initrd.service /usr/lib/dracut/modules.d/99custom/
sudo cp masterkey-luks2-initrd.sh /usr/lib/dracut/modules.d/99custom/
sudo cp 1.py /usr/lib/dracut/modules.d/99custom/

sudo dracut --force --add "custom" /boot/initramfs-$(uname -r).img $(uname -r)
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

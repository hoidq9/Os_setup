#!/bin/bash

mkdir -p /usr/lib/dracut/modules.d/99custom
cp module-setup.sh /usr/lib/dracut/modules.d/99custom/
cp myscript.sh /usr/lib/dracut/modules.d/99custom/
# cp masterkey-luks2-initrd.service /usr/lib/dracut/modules.d/99custom/
# cp masterkey-luks2-initrd.sh /usr/lib/dracut/modules.d/99custom/
# cp 1.py /usr/lib/dracut/modules.d/99custom/

dracut --force --add "custom" -v
grub2-mkconfig -o /boot/grub2/grub.cfg

#!/bin/bash
cd /keys/key_luks2_tpm2_pcr || return

pcr-oracle --rsa-generate-key --private-key my-priv.pem --authorized-policy my-auth.policy create-authorized-policy 0,4,7,14

pcr-oracle --target-platform tpm2.0 --authorized-policy my-auth.policy --input key.bin --output unsigned.tpm seal-secret

pcr-oracle --policy-name authorized-policy-test --input unsigned.tpm --output sealed.tpm --target-platform tpm2.0 --algorithm sha256 --private-key my-priv.pem --from eventlog --stop-event "grub-file=grub.cfg" --before sign 0,4,7,14

if mountpoint -q /boot/efi; then
	cp sealed.tpm /boot/efi
else
	cp sealed.tpm /custom_efi
fi

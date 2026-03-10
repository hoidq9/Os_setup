openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out /etc/systemd/tpm2-pcr-private-key.pem
openssl rsa -pubout -in /etc/systemd/tpm2-pcr-private-key.pem -out /etc/systemd/tpm2-pcr-public-key.pem

ukify -c uki.cfg build --output /boot/ukify-linux.efi
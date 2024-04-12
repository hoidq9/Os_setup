#!/bin/bash
# Install Fonts
source variables.sh

fonts() {
	# cd $HOME/Drive
	# wget $(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep browser_download_url | cut -d '"' -f 4) -O fira-code.zip
	# unzip fira-code.zip -d fira-code
	# sudo mkdir -p /usr/share/fonts/fira-code-fonts
	# sudo cp fira-code/ttf/FiraCode-SemiBold.ttf /usr/share/fonts/fira-code-fonts
	# sudo fc-cache -f -v
	# sudo dnf install abattis-cantarell-fonts.noarch adobe-source-code-pro-fonts.noarch dejavu-sans-fonts.noarch dejavu-sans-mono-fonts.noarch dejavu-serif-fonts.noarch fontconfig.x86_64 fontconfig-devel.x86_64 fonts-filesystem.noarch ghostscript-tools-fonts.x86_64 gnome-font-viewer.x86_64 google-droid-sans-fonts.noarch google-noto-cjk-fonts-common.noarch google-noto-emoji-color-fonts.noarch google-noto-fonts-common.noarch google-noto-sans-cjk-ttc-fonts.noarch google-noto-sans-gurmukhi-fonts.noarch google-noto-sans-sinhala-vf-fonts.noarch google-noto-serif-cjk-ttc-fonts.noarch jomolhari-fonts.noarch julietaula-montserrat-fonts.noarch khmer-os-system-fonts.noarch langpacks-core-font-en.noarch libXfont2.x86_64 liberation-fonts.noarch liberation-fonts-common.noarch liberation-mono-fonts.noarch liberation-sans-fonts.noarch liberation-serif-fonts.noarch libfontenc.x86_64 lohit-assamese-fonts.noarch lohit-bengali-fonts.noarch lohit-devanagari-fonts.noarch lohit-gujarati-fonts.noarch lohit-kannada-fonts.noarch lohit-odia-fonts.noarch lohit-tamil-fonts.noarch lohit-telugu-fonts.noarch paktype-naskh-basic-fonts.noarch pt-sans-fonts.noarch sil-abyssinica-fonts.noarch sil-nuosu-fonts.noarch sil-padauk-fonts.noarch smc-meera-fonts.noarch stix-fonts.noarch thai-scalable-fonts-common.noarch thai-scalable-waree-fonts.noarch urw-base35-bookman-fonts.noarch urw-base35-c059-fonts.noarch urw-base35-d050000l-fonts.noarch urw-base35-fonts.noarch urw-base35-fonts-common.noarch urw-base35-gothic-fonts.noarch urw-base35-nimbus-mono-ps-fonts.noarch urw-base35-nimbus-roman-fonts.noarch urw-base35-nimbus-sans-fonts.noarch urw-base35-p052-fonts.noarch urw-base35-standard-symbols-ps-fonts.noarch urw-base35-z003-fonts.noarch -y
	sudo dnf group install "Fonts" -y
}

fonts &>$HOME/Drive/logs/fonts.log

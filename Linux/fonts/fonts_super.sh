#!/bin/bash
# abattis-cantarell-fonts.noarch adobe-source-code-pro-fonts.noarch dejavu-sans-fonts.noarch dejavu-sans-mono-fonts.noarch dejavu-serif-fonts.noarch fontconfig.x86_64 fonts-filesystem.noarch google-droid-sans-fonts.noarch google-noto-fonts-common.noarch google-noto-sans-gurmukhi-fonts.noarch google-noto-sans-sinhala-vf-fonts.noarch jomolhari-fonts.noarch julietaula-montserrat-fonts.noarch khmer-os-system-fonts.noarch libXfont2.x86_64 liberation-fonts-common.noarch liberation-mono-fonts.noarch liberation-sans-fonts.noarch liberation-serif-fonts.noarch libfontenc.x86_64 lohit-assamese-fonts.noarch lohit-bengali-fonts.noarch lohit-devanagari-fonts.noarch lohit-gujarati-fonts.noarch lohit-kannada-fonts.noarch lohit-odia-fonts.noarch lohit-tamil-fonts.noarch lohit-telugu-fonts.noarch paktype-naskh-basic-fonts.noarch pt-sans-fonts.noarch sil-abyssinica-fonts.noarch sil-nuosu-fonts.noarch sil-padauk-fonts.noarch stix-fonts.noarch urw-base35-bookman-fonts.noarch urw-base35-c059-fonts.noarch urw-base35-d050000l-fonts.noarch urw-base35-fonts.noarch urw-base35-fonts-common.noarch urw-base35-gothic-fonts.noarch urw-base35-nimbus-mono-ps-fonts.noarch urw-base35-nimbus-roman-fonts.noarch urw-base35-nimbus-sans-fonts.noarch urw-base35-p052-fonts.noarch urw-base35-standard-symbols-ps-fonts.noarch urw-base35-z003-fonts.noarch google-noto-sans-fonts
source ../variables.sh

Main_fonts() {
	if [ "$os_id" == "rhel" ]; then
		cd $REPO_DIR || return
		wget $(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep browser_download_url | cut -d '"' -f 4) -O fira-code.zip
		unzip fira-code.zip -d fira-code
		mkdir -p /usr/share/fonts/fira-code-fonts
		cp fira-code/ttf/FiraCode-SemiBold.ttf /usr/share/fonts/fira-code-fonts
		dnf group install "Fonts" -y
		cd $REPO_DIR/
		rm -rf fira-code fira-code.zip
	fi

	if [ "$os_id" == "fedora" ]; then
		mkdir -p /usr/share/fonts/fira-code-nerd-fonts
		cd "$REPO_DIR" || return
		mkdir -p fonts_os
		cd fonts_os
		mkdir -p fira-code-nerd && wget $(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep browser_download_url | grep "FiraCode*.tar.xz" | cut -d '"' -f 4) -O fira-code-nerd.tar.xz && tar -xvf fira-code-nerd.tar.xz -C fira-code-nerd
		cd fira-code-nerd
		cp FiraCodeNerdFontMono-SemiBold.ttf /usr/share/fonts/fira-code-nerd-fonts
		dnf group install "fonts" -y
		cd $REPO_DIR/
		rm -rf fonts_os
	fi

	fc-cache -f -v
}

check_and_run Main_fonts

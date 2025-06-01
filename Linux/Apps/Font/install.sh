#!/bin/bash
# abattis-cantarell-fonts.noarch adobe-source-code-pro-fonts.noarch dejavu-sans-fonts.noarch dejavu-sans-mono-fonts.noarch dejavu-serif-fonts.noarch fontconfig.x86_64 fonts-filesystem.noarch google-droid-sans-fonts.noarch google-noto-fonts-common.noarch google-noto-sans-gurmukhi-fonts.noarch google-noto-sans-sinhala-vf-fonts.noarch jomolhari-fonts.noarch julietaula-montserrat-fonts.noarch khmer-os-system-fonts.noarch libXfont2.x86_64 liberation-fonts-common.noarch liberation-mono-fonts.noarch liberation-sans-fonts.noarch liberation-serif-fonts.noarch libfontenc.x86_64 lohit-assamese-fonts.noarch lohit-bengali-fonts.noarch lohit-devanagari-fonts.noarch lohit-gujarati-fonts.noarch lohit-kannada-fonts.noarch lohit-odia-fonts.noarch lohit-tamil-fonts.noarch lohit-telugu-fonts.noarch paktype-naskh-basic-fonts.noarch pt-sans-fonts.noarch sil-abyssinica-fonts.noarch sil-nuosu-fonts.noarch sil-padauk-fonts.noarch stix-fonts.noarch urw-base35-bookman-fonts.noarch urw-base35-c059-fonts.noarch urw-base35-d050000l-fonts.noarch urw-base35-fonts.noarch urw-base35-fonts-common.noarch urw-base35-gothic-fonts.noarch urw-base35-nimbus-mono-ps-fonts.noarch urw-base35-nimbus-roman-fonts.noarch urw-base35-nimbus-sans-fonts.noarch urw-base35-p052-fonts.noarch urw-base35-standard-symbols-ps-fonts.noarch urw-base35-z003-fonts.noarch google-noto-sans-fonts
# local font_url=$(curl -s https://api.github.com/repos/tonsky/FiraCode/releases/latest | grep browser_download_url | cut -d '"' -f 4)
# download_and_extract "$font_url" "fira-code" "fira-code.zip"
# install_font "fira-code/ttf/FiraCode-SemiBold.ttf" "/usr/share/fonts/fira-code-fonts" "$HOME/.local/share/fonts/fira-code-fonts"
# rm -rf fira-code

source ../../variables.sh

download_and_extract() {
	local url="$1"
	local dest_dir="$2"
	local output_name="$3"

	mkdir -p "$dest_dir"
	wget -q "$url" -O "$output_name"
	unzip "$output_name" -d "$dest_dir"
	rm -f "$output_name"
}

install_font() {
	local font_file="$1"
	local system_dir="$2"
	local user_dir="$3"

	if [ -f "$font_file" ]; then
		if [ "$EUID" -eq 0 ]; then
			mkdir -p "$system_dir"
			cp "$font_file" "$system_dir"
		else
			if [ ! -d "$system_dir" ]; then
				mkdir -p "$user_dir"
				cp "$font_file" "$user_dir"
			fi
		fi
	else
		exit 1
	fi
}

Apps_Font() {
	cd "$REPO_DIR" || return

	fira_code_fonts() {
		local font_url=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | grep browser_download_url | grep "FiraCode.*.zip" | cut -d '"' -f 4)
		download_and_extract "$font_url" "fira-code-nerd" "fira-code-nerd.zip"
		install_font "fira-code-nerd/FiraCodeNerdFontMono-SemiBold.ttf" "/usr/share/fonts/fira-code-nerd-fonts" "$HOME/.local/share/fonts/fira-code-nerd-fonts"
		rm -rf fira-code-nerd
	}

	adwaita_fonts() {
		if rpm -q git &>/dev/null; then
			git clone https://gitlab.gnome.org/GNOME/adwaita-fonts.git
			cd adwaita-fonts
			install_font "mono/AdwaitaMono-Regular.ttf" "/usr/share/fonts/adwaita-fonts" "$HOME/.local/share/fonts/adwaita-fonts"
			install_font "sans/AdwaitaSans-Regular.ttf" "/usr/share/fonts/adwaita-fonts" "$HOME/.local/share/fonts/adwaita-fonts"
			cd "$REPO_DIR" || return
			rm -rf adwaita-fonts
		fi
	}

	fira_code_fonts
	adwaita_fonts
	fc-cache -f -v
}

check_and_run Apps_Font "$REPO_DIR/../../logs/Apps_Font.log" "$REPO_DIR/../../logs/Result.log"

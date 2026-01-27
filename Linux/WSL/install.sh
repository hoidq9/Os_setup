#!/bin/bash
source ../variables.sh
Ohmyzsh_User() {
	if command -v zsh >/dev/null 2>&1 && command -v git >/dev/null 2>&1 && command -v wget >/dev/null 2>&1; then
		rm -rf $HOME/.zshrc.pre-oh-my-zsh*
		if [ ! -d "$HOME/.oh-my-zsh" ]; then
			mkdir -p $REPO_DIR/ohmyzsh
			cd $REPO_DIR/ohmyzsh
			wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
			sh install.sh --unattended
			declare -a gitarray
			gitarray=(
				'zsh-users/zsh-syntax-highlighting.git '$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting''
				'zsh-users/zsh-autosuggestions '$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions''
				'spaceship-prompt/spaceship-prompt.git '$HOME/.oh-my-zsh/custom/themes/spaceship-prompt''
				'TamCore/autoupdate-oh-my-zsh-plugins '$HOME/.oh-my-zsh/custom/plugins/autoupdate''
			)
			for i in "${gitarray[@]}"; do
				echo $(git clone https://github.com/$i)
			done
			ln -s $HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme $HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme
			rm -rf $HOME/.oh-my-zsh/themes
		else
			cd $HOME/.oh-my-zsh
			git pull
		fi
		cd $REPO_DIR/
		rm -rf ohmyzsh

		config_file="zshrc_cfg/_${os_id}_user.zshrc"
		if [ -f "$config_file" ]; then
			cp -f "$config_file" "$HOME/.zshrc"
		fi
		cp -f spaceshiprc_cfg/_user_spaceshiprc.zsh $HOME/.spaceshiprc.zsh
	fi
}

shfmt_install() {
	mkdir -p shfmt_install
	cd shfmt_install || return
	curl -s https://api.github.com/repos/mvdan/sh/releases/latest | grep "browser_download_url" | grep "linux_amd64" | cut -d : -f 2,3 | tr -d \" | wget -i -
	mv * shfmt
	sudo mv shfmt /usr/bin/
	sudo chmod +x /usr/bin/shfmt
	cd ..
	rm -rf shfmt_install
}

Ohmyzsh_User
shfmt_install

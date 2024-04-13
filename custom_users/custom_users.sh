#!/bin/bash
source variables.sh

download_file() {
	cd $HOME/Drive
	wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	rm -f ./install-gnome-extensions.sh
	wget -N -q "https://raw.githubusercontent.com/ToasterUwU/install-gnome-extensions/master/install-gnome-extensions.sh" -O ./install-gnome-extensions.sh && chmod +x install-gnome-extensions.sh
	git clone https://github.com/dracula/gnome-terminal
}

ohmyzsh() {
	cd $HOME/Drive
	declare -a gitarray
	gitarray=('zsh-users/zsh-syntax-highlighting.git '$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting'' 'zsh-users/zsh-autosuggestions '$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions'' 'spaceship-prompt/spaceship-prompt.git '$HOME/.oh-my-zsh/custom/themes/spaceship-prompt'' 'TamCore/autoupdate-oh-my-zsh-plugins '$HOME/.oh-my-zsh/custom/plugins/autoupdate'')
	sh install.sh --unattended
	for i in "${gitarray[@]}"; do
		echo $(git clone https://github.com/$i)
	done
	ln -s $HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme $HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme
}

terminal() {
	id=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
	profile_path="org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$id/"
	keybindings_path="org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/"
	keybindings=("copy '<Ctrl>C'" "new-tab '<Ctrl>T'" "new-window '<Ctrl>N'" "save-contents '<Ctrl>S'" "close-tab '<Ctrl>W'" "close-window '<Ctrl>Q'" "copy-html '<Ctrl>X'" "paste '<Ctrl>V'" "select-all '<Ctrl>A'" "preferences '<Ctrl>P'" "find '<Ctrl>F'" "find-next '<Ctrl>G'" "find-previous '<Ctrl>H'" "find-clear '<Ctrl>J'")
	profile=("visible-name '$(whoami)'" "cursor-shape 'ibeam'")
	for binding in "${keybindings[@]}"; do
		gsettings set $keybindings_path $binding
	done
	for setting in "${profile[@]}"; do
		gsettings set $profile_path $setting
	done
	gsettings set org.gnome.desktop.interface enable-hot-corners false
	cd $HOME/Drive/gnome-terminal
	./install.sh -s Dracula -p $(whoami) --skip-dircolors
	cd $REPO_DIR/../create_users
	if [ -f $HOME/.zshrc ]; then
		rm -rf $HOME/.zshrc
	fi
	cp .zshrc $HOME/.zshrc
	cp .spaceshiprc.zsh $HOME/.spaceshiprc.zsh
}

accessibility() {
	interface_settings=(
		"text-scaling-factor 1.25"
		"gtk-theme 'redhat-alt'"
		"icon-theme 'rhel'"
		"cursor-theme 'WhiteSur-cursors'"
		"clock-show-date true"
		"show-battery-percentage true"
		"clock-show-seconds true"
		"clock-show-weekday true"
	)
	for setting in "${interface_settings[@]}"; do
		gsettings set org.gnome.desktop.interface $setting
	done
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
	gsettings set org.gnome.desktop.session idle-delay 1800
	gsettings set org.gnome.desktop.sound allow-volume-above-100-percent true
	gsettings set org.gnome.desktop.input-sources show-all-sources true
	gsettings set org.gnome.desktop.input-sources sources "[('ibus', 'm17n:vi:telex'), ('xkb', 'us')]"
	gsettings set org.gnome.desktop.interface locate-pointer true
	gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:appmenu'
}

gnome_extensions() {
	cd $HOME/Drive
	declare -a extensions
	extensions=('1460' '4679' '3733' '5219' '120' '3628' '1486')	# '704' '2087' '1082' '1160'
	for i in "${extensions[@]}"; do
		echo $(./install-gnome-extensions.sh -e -o -u $i)
	done
}

keybinding() {
	KEY1_PATH="org.gnome.settings-daemon.plugins.media-keys.custom-keybinding"
	KEY_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"
	gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings \
		"['$KEY_PATH/custom0/']"
	# Launch Microsoft Edge
	# gsettings set $KEY1_PATH:$KEY_PATH/custom0/ name "Microsoft Edge"
	# gsettings set $KEY1_PATH:$KEY_PATH/custom0/ command "microsoft-edge-stable"
	# gsettings set $KEY1_PATH:$KEY_PATH/custom0/ binding "<Primary><Alt>E"
	# Launch Terminal
	gsettings set $KEY1_PATH:$KEY_PATH/custom0/ name "GNOME Terminal"
	gsettings set $KEY1_PATH:$KEY_PATH/custom0/ command "gnome-terminal"
	gsettings set $KEY1_PATH:$KEY_PATH/custom0/ binding "<Primary><Alt>T"
	# Switch Input Method
	# gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Z', 'XF86Keyboard']"
}

remove_file() {
	cd $HOME/Drive
	rm -rf gnome-terminal install.sh $HOME/.oh-my-zsh/themes install-gnome-extensions.sh
}

custom_users() {
	download_file
	ohmyzsh
	terminal
	accessibility
	keybinding
	gnome_extensions
	remove_file
}
custom_users &>$HOME/Drive/logs/custom_users.log

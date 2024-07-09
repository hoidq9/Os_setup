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
	extensions=('3628' '4679' '1082' '3088' '1486' '3843' '120' '3733' '5219' '1460' '4670' '307') # '704' '2087' '1160' '704'
	for i in "${extensions[@]}"; do
		echo $(./install-gnome-extensions.sh -e -o -u $i)
	done

	# Config extensions All Windows
	# sed -i 's/this\.actor\.hide();/\/\/ this.actor.hide();/g' $HOME/.local/share/gnome-shell/extensions/all-windows@ezix.org/extension.js
	# sed -i 's/Main.panel.addToStatusArea('\''window-list'\'', _windowlist, -1);/Main.panel.addToStatusArea('\''window-list'\'', _windowlist, 0, '\''right'\'');/g' $HOME/.local/share/gnome-shell/extensions/all-windows@ezix.org/extension.js

	# Config extensions CPU konkor
	sed -i "s/Main.panel.addToStatusArea ('cpufreq-indicator', monitor);/Main.panel.addToStatusArea ('cpufreq-indicator', monitor, 1, 'left');/g" $HOME/.local/share/gnome-shell/extensions/cpufreq@konkor/extension.js

	# Config extensions Extensions List
	sed -i "s/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 0, 'right')/Main.panel.addToStatusArea(Me.metadata.uuid, this._button, 1, 'right')/g" $HOME/.local/share/gnome-shell/extensions/extension-list@tu.berry/extension.js

	# Config extensions Extensions Sync
	sed -i "s/panel.addToStatusArea('extensions-sync', this.button);/panel.addToStatusArea('extensions-sync', this.button, '2', 'right');/g" $HOME/.local/share/gnome-shell/extensions/extensions-sync@elhan.io/extension.js

	# Config extensions System Monitor
	sed -i "s/panel = Main.panel._rightBox;/panel = Main.panel._leftBox;/g" $HOME/.local/share/gnome-shell/extensions/system-monitor@paradoxxx.zero.gmail.com/extension.js

	# Config extensions Top Hat
	sed -i "s/var UPDATE_INTERVAL_CPU = 2000;/var UPDATE_INTERVAL_CPU = 1000;/g" $HOME/.local/share/gnome-shell/extensions/tophat@fflewddur.github.io/lib/config.js

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

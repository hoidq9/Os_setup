export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="spaceship"
zstyle ':omz:update' mode auto

plugins=(
	git
	zsh-syntax-highlighting
	zsh-autosuggestions
	safe-paste
	jsontools
	autoupdate
	battery
	vscode
	brew
	history
)

export UPDATE_ZSH_DAYS=1
ZSH_CUSTOM_AUTOUPDATE_QUIET=true

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

export ARCHFLAGS="-arch x86_64"

alias e='exit'
alias s='sudo'
alias rlz='. ~/.zshrc'
alias h='history'
alias install='sudo dnf install'
alias remove='sudo dnf remove'
alias autoremove='sudo dnf autoremove'
alias cl='clear'
alias clean='sudo dnf clean all'
alias update= 'sudo dnf update'
alias upgrade='sudo dnf upgrade -y && flatpak update -y'
alias reinstall='sudo dnf reinstall -y'
alias info='sudo dnf info'
alias ginfo='sudo dnf groupinfo'
alias glist='sudo dnf group list'
alias ginstall='sudo dnf group install'
alias gremove='sudo dnf group remove'
alias list='sudo dnf list --installed'
alias all='sudo dnf list all'
alias dinfo='sudo dnf info'
alias search="sudo dnf search"
alias podman_jupyter='podman run --pull always --user root -e GRANT_SUDO=yes --privileged --rm -e USE_HTTPS=yes -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' -it -p 8888:8888/tcp -v $HOME/Jupyter:/home/jovyan/work --name Jupyter -w /home/jovyan/work jupyter/base-notebook:latest'
alias podman_ubuntu='podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias sudo_podman_ubuntu='sudo podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias podman_ubuntu_kde='podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias sudo_podman_ubuntu_kde='sudo podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias podman_portainer='podman run --pull always -d -p 8000:8000 -p 9443:9443 --privileged --name portainer -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z -v portainer_data:/data docker.io/portainer/portainer-ce:latest'

# alias lla='eza -l --icons --total-size --smart-group -a -A'

# TMOUT=1
# TRAPALRM() {
# 	zle reset-prompt
# }

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
alias remove='sudo dnf autoremove'
alias cl='clear'
alias clean='sudo dnf clean all'
alias update= 'sudo dnf update'
alias upgrade='sudo dnf upgrade -y'
alias reinstall='sudo dnf reinstall -y'
alias dinfo='sudo dnf info'
alias ginfo='sudo dnf groupinfo'
alias list='sudo dnf list installed'
alias all='sudo dnf list all'
alias lla='eza -l --icons --total-size --smart-group -a -A'

TMOUT=1
TRAPALRM() {
	zle reset-prompt
}

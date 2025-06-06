# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="spaceship"
zstyle ':omz:update' mode auto
# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
	bundler
	dotenv
	rake
	rbenv
	ruby
	zsh-syntax-highlighting
	zsh-autosuggestions
	web-search
	safe-paste
	history
	jsontools
	autoupdate
	battery
)
# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=7
ZSH_CUSTOM_AUTOUPDATE_QUIET=true

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases

alias e='exit'
alias s='sudo'
alias rlz='. ~/.zshrc'
alias h='history'
alias install='sudo dnf install'
alias remove='sudo dnf autoremove'
alias cl='clear'
alias search='sudo dnf search'
alias search_all='sudo dnf search all'
alias clean='sudo dnf clean all'
alias update= 'sudo dnf update'
alias upgrade='sudo dnf upgrade -y && flatpak update -y'
alias reinstall='sudo dnf reinstall -y'
alias dinfo='sudo dnf info'
alias ginfo='sudo dnf groupinfo'
alias list='sudo dnf list installed'
alias all='sudo dnf list all'
alias podman_jupyter='podman run --pull always --user root -e GRANT_SUDO=yes --privileged --rm -e USE_HTTPS=yes -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' -it -p 8888:8888/tcp -v $HOME/Jupyter:/home/jovyan/work --name Jupyter -w /home/jovyan/work jupyter/base-notebook:latest'
alias podman_ubuntu='podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias sudo_podman_ubuntu='sudo podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias podman_ubuntu_kde='podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias sudo_podman_ubuntu_kde='sudo podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias podman_portainer='podman run --pull always -d -p 8000:8000 -p 9443:9443 --privileged --name portainer -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z -v portainer_data:/data docker.io/portainer/portainer-ce:latest'

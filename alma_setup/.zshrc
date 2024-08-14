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
	# redis-cli
	# laravel
	# eza
	# rails
	# toolbox
	# fasd
	# wakeonlan
	# ant
	# hanami
	# vault
	# magic-enter
	# hitokoto
	# kube-ps1
	# kitchen
	# dnf
	# svcat
	# tmux-cssh
	# git-lfs
	# sudo
	# doctl
	# sfffe
	# stack
	# charm
	# perms
	# procs
	# gradle
	# istioctl
	# gem
	# gas
	# ros
	# mongo-atlas
	# postgres
	# n98-magerun
	# azure
	# frontend-search
	# globalias
	# composer
	# emacs
	# grails
	# conda-env
	# brew
	# shell-proxy
	# mix
	# knife_ssh
	# node
	# systemd
	# firewalld
	# colemak
	# jsontools
	# safe-paste
	# terminitor
	# bgnotify
	# dotenv
	# encode64
	# cabal
	# phing
	# virtualenv
	# vundle
	# fancy-ctrl-z
	# ubuntu
	# docker-machine
	# copyfile
	# pip
	# jump
	# marktext
	# laravel5
	# gitfast
	# web-search
	# swiftpm
	# docker
	# cloudfoundry
	# perl
	# bbedit
	# pep8
	# pm2
	# aws
	# isodate
	# branch
	# rbenv
	# github
	# bazel
	# extract
	# pylint
	# git-commit
	# autoenv
	# gatsby
	# multipass
	# pyenv
	# repo
	# knife
	# scw
	# kubectl
	# bridgetown
	# cp
	# git-extras
	# iterm2
	# mysql-macports
	# rand-quote
	# apache2-macports
	# dirhistory
	# jenv
	# mvn
	# stripe
	# mise
	# git-flow
	# marked2
	# glassfish
	# ng
	# kind
	# mix-fast
	# last-working-dir
	# vim-interaction
	# autojump
	# svn-fast-info
	# octozen
	# zsh-navigation-tools
	# archlinux
	# profiles
	# ember-cli
	# bedtools
	# coffee
	# emoji
	# juju
	# dircycle
	# kitty
	# cpanm
	# vagrant
	# transfer
	# chruby
	# term_tab
	# jira
	# symfony6
	# emotty
	# wp-cli
	# poetry-env
	# qodana
	# cake
	# fbterm
	# bun
	# asdf
	# golang
	# xcode
	# percol
	# virtualenvwrapper
	# docker-compose
	# git-hubflow
	# forklift
	# sublime
	# dbt
	# fnm
	# laravel4
	# supervisor
	# tig
	# cask
	# yii
	# drush
	# vi-mode
	# dotnet
	# nmap
	# rbfu
	# argocd
	# lol
	# z
	# alias-finder
	# direnv
	# fossil
	# compleat
	# qrcode
	# emoji-clock
	# heroku
	# yii2
	# pod
	# jhbuild
	# deno
	# svn
	# lxd
	# jfrog
	# lighthouse
	# ruby
	# colored-man-pages
	# gpg-agent
	# kops
	# nats
	# powder
	# opentofu
	# git-auto-fetch
	# tmux
	# fig
	# helm
	# git-prompt
	# dirpersist
	# python
	# grc
	# sublime-merge
	# pass
	# hasura
	# mercurial
	# common-aliases
	# oc
	# per-directory-history
	# fzf
	# 1password
	# sigstore
	# pj
	# kubectx
	# invoke
	# flutter
	# git
	# tmuxinator
	# skaffold
	# copybuffer
	# gnu-utils
	# npm
	# salt
	# mongocli
	# symfony2
	# kn
	# git-escape-magic
	# gulp
	# httpie
	# command-not-found
	# sfdx
	# timer
	# kate
	# snap
	# rebar
	# pow
	# paver
	# debian
	# mosh
	# ipfs
	# taskwarrior
	# thor
	# jruby
	# scd
	# yum
	# pipenv
	# sbt
	# man
	# gitignore
	# tldr
	# vagrant-prompt
	# fabric
	# macos
	# nanoc
	# ionic
	# minikube
	# zeus
	# bundler
	# rake-fast
	# poetry
	# grunt
	# droplr
	# react-native
	# thefuck
	# gh
	# otp
	# textastic
	# screen
	# please
	# ssh-agent
	# nvm
	# dnote
	# rsync
	# ansible
	# history-substring-search
	# vscode
	# fluxcd
	# autopep8
	# codeclimate
	# chucknorris
	# shrink-path
	# microk8s
	# gcloud
	# volta
	# powify
	# lpass
	# watson
	# suse
	# samtools
	# universalarchive
	# zoxide
	# nodenv
	# arcanist
	# textmate
	# operator-sdk
	# keychain
	# wd
	# macports
	# bower
	# pre-commit
	# homestead
	# zsh-interactive-cd
	# tugboat
	# sprunge
	# genpass
	# zbell
	# dash
	# rvm
	# scala
	# geeknote
	# copypath
	# podman
	# aliases
	# battery
	# urltools
	# rbw
	# history
	# rust
	# systemadmin
	# lein
	# celery
	# ssh
	# torrent
	# singlechar
	# cakephp3
	# eecms
	# terraform
	# symfony
	# jake-node
	# lando
	# capistrano
	# hitchhiker
	# themes
	# nomad
	# ufw
	# meteor
	# yarn
	# git-flow-avh
	# rake
	# spring
	# catimg
	# colorize
	# fastfile
	# sdk
)
# Uncomment the following line to change how often to auto-update (in days).
export UPDATE_ZSH_DAYS=2
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
# eval $(thefuck --alias)
# You can use whatever you want as an alias, like for Mondays:
# eval $(thefuck --alias FUCK)
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
alias podman_jupyter='podman run --pull always --user root -e GRANT_SUDO=yes --privileged --rm -e USE_HTTPS=yes -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' -it -p 8888:8888/tcp -v $HOME/Jupyter:/home/jovyan/work --name Jupyter -w /home/jovyan/work jupyter/base-notebook:latest'
alias podman_ubuntu='podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias sudo_podman_ubuntu='sudo podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias podman_ubuntu_kde='podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias sudo_podman_ubuntu_kde='sudo podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias podman_portainer='podman run --pull always -d -p 8000:8000 -p 9443:9443 --privileged --name portainer -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z -v portainer_data:/data docker.io/portainer/portainer-ce:latest'
# general
alias h='heroku'
alias hauto='heroku autocomplete $(echo $SHELL)'
alias hl='heroku local'

# log
alias hg='heroku logs'
alias hgt='heroku log tail'

# database
alias hpg='heroku pg'
alias hpsql='heroku pg:psql'
alias hpb='heroku pg:backups'
alias hpbc='heroku pg:backups:capture'
alias hpbd='heroku pg:backups:download'
alias hpbr='heroku pg:backups:restore'

# config
alias hc='heroku config'
alias hca='heroku config -a'
alias hcr='heroku config -r'
alias hcs='heroku config:set'
alias hcu='heroku config:unset'

# this function allow to load multi env set in a file
hcfile() {
	echo 'Which platform [-r/a name] ?'
	read platform
	echo 'Which file ?'
	read file
	while read line; do
		heroku config:set "$platform" "$line"
	done <"$file"
}

# apps and favorites
alias ha='heroku apps'
alias hpop='heroku create'
alias hkill='heroku apps:destroy'
alias hlog='heroku apps:errors'
alias hfav='heroku apps:favorites'
alias hfava='heroku apps:favorites:add'
alias hfavr='heroku apps:favorites:remove'
alias hai='heroku apps:info'
alias hair='heroku apps:info -r'
alias haia='heroku apps:info -a'

# auth
alias h2fa='heroku auth:2fa'
alias h2far='heroku auth:2fa:disable'

# access
alias hac='heroku access'
alias hacr='heroku access -r'
alias haca='heroku access -a'
alias hadd='heroku access:add'
alias hdel='heroku access:remove'
alias hup='heroku access:update'

# addons
alias hads='heroku addons -A'
alias hada='heroku addons -a'
alias hadr='heroku addons -r'
alias hadat='heroku addons:attach'
alias hadc='heroku addons:create'
alias hadel='heroku addons:destroy'
alias hadde='heroku addons:detach'
alias hadoc='heroku addons:docs'

# login
alias hin='heroku login'
alias hout='heroku logout'
alias hi='heroku login -i'
alias hwho='heroku auth:whoami'

# authorizations
alias hth='heroku authorizations'
alias hthadd='heroku authorizations:create'
alias hthif='heroku authorizations:info'
alias hthdel='heroku authorizations:revoke'
alias hthrot='heroku authorizations:rotate'
alias hthup='heroku authorizations:update'

# plugins
alias hp='heroku plugins'

# cert
alias hssl='heroku certs'
alias hssli='heroku certs:info'
alias hssla='heroku certs:add'
alias hsslu='heroku certs:update'
alias hsslr='heroku certs:remove'



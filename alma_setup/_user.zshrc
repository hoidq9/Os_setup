# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"
zstyle ':omz:update' mode auto

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

plugins=(
	git
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
	vscode
	docker
	systemadmin
	podman
	ssh
	# git
	# bundler
	# dotenv
	# rake
	# rbenv
	# zsh-syntax-highlighting
	# zsh-autosuggestions
	# web-search
	# safe-paste
	# history
	# jsontools
	# autoupdate
	# battery
	# redis-cli
	# laravel
	# rails
	# toolbox
	# fasd
	# wakeonlan
	# ant
	# hanami
	# magic-enter
	# kube-ps1
	# kitchen
	# dnf
	# svcat
	# git-lfs
	# sudo
	# doctl
	# stack
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
	# grails
	# brew
	# shell-proxy
	# mix
	# knife_ssh
	# node
	# systemd
	# firewalld
	# bgnotify
	# encode64
	# virtualenv
	# fancy-ctrl-z
	# copyfile
	# pip
	# marktext
	# laravel5
	# gitfast
	# docker
	# cloudfoundry
	# perl
	# pep8
	# aws
	# isodate
	# branch
	# github
	# bazel
	# extract
	# pylint
	# git-commit
	# gatsby
	# pyenv
	# repo
	# knife
	# scw
	# kubectl
	# bridgetown
	# cp
	# git-extras
	# rand-quote
	# dirhistory
	# jenv
	# mvn
	# stripe
	# mise
	# git-flow
	# marked2
	# glassfish
	# kind
	# mix-fast
	# last-working-dir
	# svn-fast-info
	# zsh-navigation-tools
	# profiles
	# ember-cli
	# bedtools
	# coffee
	# emoji
	# juju
	# dircycle
	# cpanm
	# vagrant
	# transfer
	# term_tab
	# jira
	# symfony6
	# emotty
	# poetry-env
	# qodana
	# cake
	# fbterm
	# bun
	# asdf
	# percol
	# golang
	# docker-compose
	# git-hubflow
	# forklift
	# dbt
	# fnm
	# laravel4
	# supervisor
	# tig
	# yii
	# dotnet
	# nmap
	# alias-finder
	# rbfu
	# argocd
	# lol
	# z
	# direnv
	# fossil
	# compleat
	# qrcode
	# emoji-clock
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
	# fig
	# helm
	# git-prompt
	# dirpersist
	# python
	# grc
	# pass
	# hasura
	# mercurial
	# oc
	# per-directory-history
	# 1password
	# sigstore
	# pj
	# kubectx
	# invoke
	# flutter
	# git
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
	# snap
	# rebar
	# pow
	# paver
	# mosh
	# ipfs
	# taskwarrior
	# thor
	# jruby
	# scd
	# yum
	# sbt
	# gitignore
	# tldr
	# vagrant-prompt
	# fabric
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
	# gh
	# otp
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
	# shrink-path
	# microk8s
	# gcloud
	# lpass
	# watson
	# samtools
	# universalarchive
	# nodenv
	# arcanist
	# textmate
	# operator-sdk
	# keychain
	# wd
	# bower
	# pre-commit
	# zsh-interactive-cd
	# tugboat
	# sprunge
	# genpass
	# rvm
	# scala
	# geeknote
	# copypath
	# podman
	# aliases
	# urltools
	# rbw
	# rust
	# systemadmin
	# lein
	# celery
	# ssh
	# torrent
	# singlechar
	# eecms
	# terraform
	# jake-node
	# lando
	# capistrano
	# nomad
	# ufw
	# meteor
	# git-flow-avh
	# rake
	# spring
	# colorize
	# fastfile
	# sdk
	# themes
)

# Uncomment the following line to change how often to auto-update (in days).
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
alias podman_jupyter='podman run --pull always --user root -e GRANT_SUDO=yes --privileged --rm -e USE_HTTPS=yes -e CHOWN_HOME=yes -e CHOWN_HOME_OPTS='-R' -it -p 8888:8888/tcp -v $HOME/Jupyter:/home/jovyan/work --name Jupyter -w /home/jovyan/work jupyter/base-notebook:latest'
alias podman_ubuntu='podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias sudo_podman_ubuntu='sudo podman run --pull always --rm --network=host -v "$HOME/Ubuntu":/usr/src/ubuntu -w /usr/src/ubuntu -it --privileged ubuntu:latest'
alias podman_ubuntu_kde='podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias sudo_podman_ubuntu_kde='sudo podman run --pull always -it --rm -d --privileged -p 3000:3000/tcp -p 3001:3001/tcp linuxserver/webtop:ubuntu-kde'
alias podman_portainer='podman run --pull always -d -p 8000:8000 -p 9443:9443 --privileged --name portainer -v /run/user/1000/podman/podman.sock:/var/run/docker.sock:Z -v portainer_data:/data docker.io/portainer/portainer-ce:latest'
alias lla='eza -l --icons --total-size --smart-group -a -A'

TMOUT=1
TRAPALRM() {
	zle reset-prompt
}

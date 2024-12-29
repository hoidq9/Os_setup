#!/bin/bash
source ../../variables.sh

Apps_Gcm() {
    if ! command -v git &>/dev/null; then
        echo "Git is not installed. Please install Git first."
        exit 1
    fi

    local install_dir
    mkdir -p "$REPO_DIR/Gcm_install"
    cd "$REPO_DIR/Gcm_install" || exit

    curl -s https://api.github.com/repos/ldennington/git-credential-manager/releases/latest |
        grep -Eo 'https://[^"]*gcm-linux.*[0-9]+\.[0-9]+\.[0-9]+\.tar\.gz' |
        xargs -I 'url' curl -LO 'url'
    local gcm_file=$(ls gcm*.tar.gz)

    if [ "$EUID" -eq 0 ]; then
        install_dir="/usr/local/bin"
    else
        if [ ! -f "/usr/local/bin/git-credential-manager" ]; then
            install_dir="$HOME/Prj/Gcm"
            mkdir -p "$install_dir"
        fi
    fi

    tar -xvf "$gcm_file" -C "$install_dir"
    chmod +x "$install_dir/git-credential-manager"
    "$install_dir/git-credential-manager" configure

    git config --global credential.credentialStore secretservice

    cd "$REPO_DIR" || exit
    rm -rf "$REPO_DIR/Gcm_install"

}

check_and_run Apps_Gcm "$REPO_DIR/../../logs/Apps_Gcm.log" "$REPO_DIR/../../logs/Result.log"

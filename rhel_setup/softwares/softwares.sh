#!/bin/bash
source variables.sh
cd $REPO_DIR

microsoft() {
    sudo cp vscode.repo microsoft-edge.repo /etc/yum.repos.d/
}

gcm() {
    cd $HOME/Drive
    gcm_install() {
        curl -s https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest | grep "browser_download_url" | grep -v "symbol" | grep "linux" | grep "tar.gz" | cut -d : -f 2,3 | tr -d \" | wget -i -
        gcm_file=$(ls gcm*.tar.gz)
        sudo tar -xvf $gcm_file -C /usr/local/bin
        git-credential-manager configure
    }
    if [ command -v git-credential-manager ] &>/dev/null; then
        git-credential-manager unconfigure
        sudo rm -rf $(command -v git-credential-manager)
        gcm_install
    else
        gcm_install
    fi
    git config --global credential.credentialStore secretservice
}

install() {
    microsoft
    gcm
    # shfmt
    warp
}

install &>$HOME/Drive/logs/softwares.log

#!/bin/bash
source ../../variables.sh

Apps_Yubico() {
    if [ ! -d "$HOME/Prj/Yubico" ]; then
        mkdir -p $HOME/Prj/Yubico
    fi
    cd "$HOME/Prj/Yubico" || return
    rm -rf *
    wget $(curl -s https://api.github.com/repos/Yubico/yubioath-flutter/releases/latest | grep "browser_download_url" | grep "linux" | grep "tar.gz" | cut -d '"' -f 4)
    yubico_compress=$(ls -d *.tar.gz)
    dir_name=$(basename $yubico_compress .tar.gz)
    mkdir -p $dir_name
    tar -xzvf $yubico_compress -C $dir_name --strip-components=1
    cd "$dir_name" || return
    # ./desktop_integration.sh -i
    cd "$HOME/Prj/Yubico" || return
    rm -rf *.tar.gz *.tar.gz.sig
}

check_and_run Apps_Yubico "$REPO_DIR/../../logs/Apps_Yubico.log" "$REPO_DIR/../../logs/Result.log"
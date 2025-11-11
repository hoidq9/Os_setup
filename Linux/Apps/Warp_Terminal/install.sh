#!/bin/bash
source ../../variables.sh

Apps_Warp_Terminal() {
    cd "$REPO_DIR"
    wget https://app.warp.dev/get_warp?package=rpm -O warp_terminal.rpm
    rpm -i warp_terminal.rpm
    rm warp_terminal.rpm
}

# check_and_run Apps_Warp_Terminal "$REPO_DIR/../../logs/Apps_Warp_Terminal.log" "$REPO_DIR/../../logs/Result.log"

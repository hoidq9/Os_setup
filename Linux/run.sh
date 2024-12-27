#!/bin/bash
source $(pwd)/variables.sh

find "$REPO_DIR" -type f -print0 | xargs -0 dos2unix -- &>/dev/null
rm -rf logs
[ ! -d $HOME/Prj ] && mkdir -p $HOME/Prj
mkdir -p $REPO_DIR/logs
folders_run_sudo=(
    # system
    bootloader
)

for name in ${folders_run_sudo[@]}; do
    cd $REPO_DIR/$name
    sudo sh $name.sh
done
# sh normal_user


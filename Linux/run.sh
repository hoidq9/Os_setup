#!/bin/bash
source $(pwd)/variables.sh

find "$REPO_DIR" -type f -print0 | xargs -0 dos2unix -- &>/dev/null
rm -rf logs
[ ! -d $HOME/Prj ] && mkdir -p $HOME/Prj
mkdir -p $REPO_DIR/logs
sudo sh list_super.sh
sh setup_user/user_config.sh


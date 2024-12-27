#!/bin/bash
if [ ! -d $(pwd)/logs ]; then
    mkdir -p "$(pwd)/logs"
fi

if [ ! -d $(pwd)/log ]; then
    mkdir -p "$(pwd)/log"
    touch "$(pwd)/log/Result.log"
fi

source "$(pwd)/variables.sh"
find "$REPO_DIR" -type f -print0 | xargs -0 dos2unix -- &>/dev/null

if grep -q "Done" "$REPO_DIR/log/Result.log"; then
    rm -rf $REPO_DIR/logs/*
    echo "" >"$REPO_DIR/log/Result.log"
fi

if [ ! -s "$REPO_DIR/log/Result.log" ]; then
    rm -rf $REPO_DIR/logs/*
fi

if grep -q "Failed" "$REPO_DIR/log/Result.log"; then
    grep "Failed" "$REPO_DIR/log/Result.log" | while read -r line; do
        task_name=$(echo "$line" | awk -F': ' '{print $1}')
        log_file="$REPO_DIR/logs/$task_name.log"
        if [ -f "$log_file" ]; then
            rm -rf "$log_file"
        fi
    done
    sed -i '/Failed/d' "$REPO_DIR/log/Result.log"
fi

[ ! -d "$HOME/Prj" ] && mkdir -p "$HOME/Prj"
sudo sh list_super.sh
cd setup_user || exit
sh user_config.sh

if ! grep -q "Failed" "$REPO_DIR/log/Result.log"; then
    echo "Done" >>"$REPO_DIR/log/Result.log"
fi

cd "$REPO_DIR" || exit

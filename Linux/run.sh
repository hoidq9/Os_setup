#!/bin/bash
source "$(pwd)/variables.sh"

if [ ! -d $REPO_DIR/logs ]; then
    mkdir -p "$REPO_DIR/logs"
fi

touch $REPO_DIR/logs/Result.log

find "$REPO_DIR" -type f -print0 | xargs -0 dos2unix -- &>/dev/null

if grep -q "Done" "$REPO_DIR/logs/Result.log" &>/dev/null; then
    rm -rf $REPO_DIR/logs/*
    echo "" >"$REPO_DIR/logs/Result.log"
fi

if [ ! -s "$REPO_DIR/logs/Result.log" ]; then
    rm -rf $REPO_DIR/logs/*
fi

if grep -q "Failed" "$REPO_DIR/logs/Result.log" &>/dev/null; then
    grep "Failed" "$REPO_DIR/logs/Result.log" | while read -r line; do
        task_name=$(echo "$line" | awk -F': ' '{print $1}')
        log_file="$REPO_DIR/logs/$task_name.log"
        if [ -f "$log_file" ]; then
            rm -rf "$log_file"
        fi
    done
    sed -i '/Failed/d' "$REPO_DIR/logs/Result.log"
fi

[ ! -d "$HOME/Prj" ] && mkdir -p "$HOME/Prj"

cd $REPO_DIR
if id -nG "$user_current" | grep -q '\bwheel\b'; then
    sudo sh super.sh
    sh normal.sh
else
    sh normal.sh
fi

if ! grep -q "Failed" "$REPO_DIR/logs/Result.log" &>/dev/null; then
    echo "Done" >>"$REPO_DIR/logs/Result.log"
fi

cd "$REPO_DIR" || exit

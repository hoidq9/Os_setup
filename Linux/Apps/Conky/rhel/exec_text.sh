#!/bin/bash
REPO_DIR="$(dirname "$(readlink -m "${0}")")"

cd $HOME/Conky
sleep 10
./conky.AppImage -c $REPO_DIR/conky_text.conf

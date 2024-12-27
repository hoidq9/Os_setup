#!/bin/bash

REPO_DIR="$(dirname "$(readlink -m "${0}")")"
user_current=$(logname)
os_id=$(awk -F= '/^ID=/{print $2}' /etc/os-release)
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m' # Không màu

check_and_run() {
    local task_name="$1"
    local log_file="$REPO_DIR/../logs/$task_name.log"
    if grep -q "Task completed" "$log_file" 2>/dev/null; then
        echo ""
        echo "Task $task_name: Already completed, skipping."
    else
        echo "" # Print an empty line for spacing
        echo -e "${YELLOW}Task $task_name: Start${NC}"
        sleep 3
        echo -e "\033[A\033[K${RED}Task $task_name: Running${NC}"
        if $task_name &>>"$log_file"; then
            echo -e "\033[A\033[K${GREEN}Task $task_name: Done${NC}"
            echo "Task completed" >>"$log_file"
        else
            echo "Task $task_name encountered an error. Check $log_file for details."
            exit 1
        fi
    fi
}

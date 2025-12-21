#!/bin/bash

# Astra Hot Reload Watcher
# Usage: ./watch.sh [files_to_watch...]
# Example: ./watch.sh "*.lua" "lib/" "config/"

set -e

# Default command to run
COMMAND="astra run main.lua"
WATCH_FILES=("main.lua")

# Use provided files if any
if [ $# -gt 0 ]; then
    WATCH_FILES=("$@")
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Astra Hot Reload Watcher${NC}"
echo -e "${GREEN}Watching:${NC} ${WATCH_FILES[*]}"
echo -e "${GREEN}Command:${NC} $COMMAND"
echo "Press Ctrl+C to stop"
echo "----------------------------------------"

# Function to kill process if running
kill_process() {
    if [ ! -z "$PROCESS_PID" ] && kill -0 "$PROCESS_PID" 2>/dev/null; then
        echo -e "${YELLOW}Stopping process (PID: $PROCESS_PID)...${NC}"
        kill "$PROCESS_PID" 2>/dev/null || true
        # Give it a moment to clean up
        for i in {1..5}; do
            if ! kill -0 "$PROCESS_PID" 2>/dev/null; then
                break
            fi
            sleep 0.2
        done
        # Force kill if still running
        if kill -0 "$PROCESS_PID" 2>/dev/null; then
            echo -e "${RED}Force killing process...${NC}"
            kill -9 "$PROCESS_PID" 2>/dev/null || true
        fi
        wait "$PROCESS_PID" 2>/dev/null || true
        PROCESS_PID=""
    fi
}

# Function to start the process
start_process() {
    echo -e "${GREEN}Starting: $COMMAND${NC}"
    $COMMAND &
    PROCESS_PID=$!
    echo -e "${GREEN}Process started with PID: $PROCESS_PID${NC}"
}

# Function to get list of files to watch
get_watch_files() {
    local files=""
    for pattern in "${WATCH_FILES[@]}"; do
        if [[ "$pattern" == *"/" ]]; then
            # It's a directory, find all files in it
            if [ -d "${pattern%/}" ]; then
                files+="$(find "${pattern%/}" -type f) "
            fi
        elif [[ "$pattern" == *"*"* ]]; then
            # It's a glob pattern
            files+="$(find . -name "$pattern" -type f 2>/dev/null || echo '') "
        elif [ -f "$pattern" ]; then
            # It's a specific file
            files+="$pattern "
        fi
    done
    echo "$files" | tr ' ' '\n' | sort -u | grep -v "^$"
}

# Function to calculate checksum of watched files
calculate_checksum() {
    local files
    files=$(get_watch_files)
    if [ -z "$files" ]; then
        echo "nowatch"
        return
    fi
    # Use md5sum if available, otherwise use stat for modification times
    if command -v md5sum &> /dev/null; then
        # Use MD5 checksums
        md5sum $files 2>/dev/null | md5sum | awk '{print $1}'
    else
        # Use modification times (less accurate but works)
        stat -f "%m" $files 2>/dev/null | md5sum | awk '{print $1}'
    fi
}

# Function to check for file changes
check_for_changes() {
    local current_checksum
    current_checksum=$(calculate_checksum)
    
    if [ "$last_checksum" != "$current_checksum" ]; then
        if [ "$last_checksum" != "" ]; then
            echo -e "\n${YELLOW}📁 File change detected!${NC}"
            return 0  # Changes detected
        fi
        last_checksum="$current_checksum"
    fi
    return 1  # No changes
}

# Trap Ctrl+C for clean exit
cleanup() {
    echo -e "\n${RED}👋 Shutting down...${NC}"
    kill_process
    exit 0
}
trap cleanup SIGINT SIGTERM

# Initial checksum
last_checksum=$(calculate_checksum)
echo -e "${GREEN}Initial checksum: ${last_checksum:0:8}...${NC}"

# Start the process for the first time
start_process

# Main watch loop
while true; do
    # Check for process exit
    if [ ! -z "$PROCESS_PID" ] && ! kill -0 "$PROCESS_PID" 2>/dev/null; then
        echo -e "${RED}❌ Process died! Exit code: $?${NC}"
        PROCESS_PID=""
    fi
    
    # Check for file changes
    if check_for_changes; then
        kill_process
        # Small delay to ensure files are fully written
        sleep 0.5
        start_process
        last_checksum=$(calculate_checksum)
    fi
    
    # Restart if process isn't running (crashed)
    if [ -z "$PROCESS_PID" ]; then
        echo -e "${YELLOW}🔄 Process not running, restarting...${NC}"
        start_process
    fi
    
    # Wait a bit before checking again
    sleep 1
done

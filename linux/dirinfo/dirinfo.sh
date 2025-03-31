#!/bin/bash

# -----------------------------------------------------------------------------
# Script: dirinfo.sh
# Description: This script analyzes a directory and outputs information about
#              its subdirectories in either a human-readable format or JSON.
#
# Usage:
#   dirinfo.sh [-j|--json] <directory> <depth>
#
# Arguments:
#   -j, --json      Output in JSON format.
#   <directory>     The directory to analyze (default: ".").
#   <depth>         The maximum depth to traverse (default: 1).
#
# Example:
#   dirinfo.sh -j /path/to/directory 2
# -----------------------------------------------------------------------------

# Function to check if a command is installed
check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it to proceed." >&2
        exit 1
    fi
}

# Check if jq is installed if JSON output is requested
output_format="human"
if [[ "$1" == "-j" || "$1" == "--json" ]]; then
    check_command_installed "jq"
    output_format="json"
    shift
fi

# Set default directory and depth
DIRECTORY=${1:-"."}
DEPTH=${2:-1}

# Check if the directory exists
if [ ! -d "$DIRECTORY" ]; then
    echo "ERROR: Directory '$DIRECTORY' does not exist." >&2
    exit 1
fi

# Function to get directory information
get_dir_info() {
    local dir="$1"

    local INFO=$(ls -ld "$dir" 2>/dev/null)
    if [ -z "$INFO" ]; then
        echo "ERROR: Could not get info for $dir" >&2
        return 1
    fi

    local SIZE=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
    local PERM_SIMB=$(echo "$INFO" | awk '{print $1}')
    local OWNER=$(echo "$INFO" | awk '{print $3}')
    local GROUP=$(echo "$INFO" | awk '{print $4}')

    # Convert permissions to numeric format
    local PERM_NUM=0
    for ((i=0; i<9; i++)); do
        local CHAR=${PERM_SIMB:$((i+1)):1}
        if [[ "$CHAR" == "r" ]]; then ((PERM_NUM+=4*(2**(8-i)))); fi
        if [[ "$CHAR" == "w" ]]; then ((PERM_NUM+=2*(2**(8-i)))); fi
        if [[ "$CHAR" == "x" ]]; then ((PERM_NUM+=1*(2**(8-i)))); fi
    done

    echo "{"
    echo "  \"name\": \"$dir\","
    echo "  \"owner\": \"$OWNER\","
    echo "  \"group\": \"$GROUP\","
    echo "  \"size\": \"$SIZE\","
    echo "  \"permissions_numeric\": \"$PERM_NUM\","
    echo "  \"permissions_symbolic\": \"$PERM_SIMB\""
    echo "}"

    return 0
}

# Find directories and output information
if [ "$output_format" == "json" ]; then
    echo "["
    FIRST=1
    find "$DIRECTORY" -maxdepth "$DEPTH" -type d 2>/dev/null | while IFS= read -r dir; do
        if [ $FIRST -eq 0 ]; then
            echo ","
        else
            FIRST=0
        fi
        get_dir_info "$dir"
    done
    echo ""
    echo "]"
else
    # Define colors using `tput` (compatible with any terminal)
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    YELLOW=$(tput setaf 3)
    BLUE=$(tput setaf 4)
    CYAN=$(tput setaf 6)
    RESET=$(tput sgr0)

    echo -e "${BLUE}📌 Analizando '$DIRECTORY' hasta $DEPTH niveles de profundidad...${RESET}"

    # Table header
    printf "\n${YELLOW}%-40s %-12s %-12s %-10s %-10s %-10s${RESET}\n" "Nombre" "Propietario" "Grupo" "Tamaño" "Perm. Num" "Perm. Simb"

    find "$DIRECTORY" -maxdepth "$DEPTH" -type d 2>/dev/null | while IFS= read -r dir; do
        # Show which folder is being processed
        echo -ne "${CYAN}🔍 Procesando: ${dir}...${RESET} \r"

        local INFO=$(ls -ld "$dir" 2>/dev/null)
        if [ -z "$INFO" ]; then
            continue  # If info could not be obtained, go to the next
        fi

        local SIZE=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        local PERM_SIMB=$(echo "$INFO" | awk '{print $1}')
        local OWNER=$(echo "$INFO" | awk '{print $3}')
        local GROUP=$(echo "$INFO" | awk '{print $4}')

        # Convert permissions to numeric format
        local PERM_NUM=0
        for ((i=0; i<9; i++)); do
            local CHAR=${PERM_SIMB:$((i+1)):1}
            if [[ "$CHAR" == "r" ]]; then ((PERM_NUM+=4*(2**(8-i)))); fi
            if [[ "$CHAR" == "w" ]]; then ((PERM_NUM+=2*(2**(8-i)))); fi
            if [[ "$CHAR" == "x" ]]; then ((PERM_NUM+=1*(2**(8-i)))); fi
        done

        # Print the results in real time
        printf "${GREEN}%-40s %-12s %-12s %-10s %-10o %-10s${RESET}\n" "$dir" "$OWNER" "$GROUP" "$SIZE" "$PERM_NUM" "$PERM_SIMB"

    done

    # Clean the progress line
    echo -ne "\033[2K\r"
fi
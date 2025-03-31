#!/bin/bash
# Script documentation
# This script has an optional -s or --search argument that can be used to filter commands by the provided keyword.
# If no keyword is provided, the script simply deduplicates the commands and saves them to an output file.
# To run the script, save it to a file named backup-history.sh, make it executable with chmod +x backup-history.sh, and then run it with the command ./backup-history.sh.
# If you want to filter commands by a keyword, you can do so with the command ./backup-history.sh -s keyword.
# Output file
output_file="deduplicated_commands.txt"

# Function to show help
# Usage: show_help
# Displays the usage information for the script.
function show_help() {
    echo "Usage: $0 [-s|--search keyword]"
    echo "  -s, --search    Filter commands by the provided keyword"
}

# Function to get the history file based on the shell
# Usage: get_history_file
# Returns the path to the history file based on the current shell.
function get_history_file() {
    case "$SHELL" in
        */bash)
            echo "$HOME/.bash_history"
            ;;
        */zsh)
            echo "$HOME/.zsh_history"
            ;;
        *)
            echo "Unsupported shell"
            exit 1
            ;;
    esac
}

# Function to process history file
# Usage: process_history history_file keyword
# Processes the history file, deduplicates commands, and optionally filters by keyword.
# Arguments:
#   history_file - The path to the history file.
#   keyword - The keyword to filter commands (optional).
function process_history() {
    local history_file=$1
    local keyword=$2

    if [[ "$SHELL" == */zsh ]]; then
        awk -F ';' '{print $2}' "$history_file" | awk '!seen[$0]++' | grep -i "$keyword"
    else
        awk '!seen[$0]++' "$history_file" | grep -i "$keyword"
    fi
}

# Main function
# Usage: main
# The main logic of the script. Processes command-line arguments and calls other functions.
function main() {
    # Get the history file based on the shell
    history_file=$(get_history_file)

    # Check if the -s or --search argument is provided
    if [[ "$1" == "-s" || "$1" == "--search" ]]; then
        if [[ -z "$2" ]]; then
            echo "Error: A keyword is required for search"
            show_help
            exit 1
        fi
        keyword="$2"
        # Process history file with keyword filtering
        process_history "$history_file" "$keyword" > "$output_file"
    else
        # Process history file without keyword filtering
        process_history "$history_file" "" > "$output_file"
    fi

    # Display the content of the output file
    cat "$output_file"
}

# Call the main function with all the script arguments
main "$@"
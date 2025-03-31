#!/bin/bash

# -----------------------------------------------------------------------------
# Script: connect.sh
# Description: This script allows connecting to remote servers via SSH using
#              configurations stored in a JSON file.
#
# Usage:
#   ./connect.sh [-v|--verbose] [-h|--help] [connect <number>]
#
# Configuration File:
#   .servers.json - Contains the server configurations in JSON format.
#   Example format:
#   {
#       "servers": [
#           {
#               "name": "server1",
#               "user": "user1",
#               "key": "key1",
#               "ip": "192.168.1.1",
#               "port": 22
#           },
#           {
#               "name": "server2",
#               "user": "user2",
#               "password": "password2",
#               "ip": "192.168.1.2",
#               "port": 2222
#           }
#       ]
#   }
#
# Requirements:
#   - jq: Command-line tool for processing JSON.
#   - nc: Netcat, to test the connection to the server.
#   - sshpass: Tool for passing passwords to ssh.
#
# -----------------------------------------------------------------------------

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Variable to control verbosity
VERBOSE=0

# Function to print verbose messages
log() {
    if [ $VERBOSE -eq 1 ]; then
        echo -e "$1"
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}Usage:${NC} ./connect.sh [-v|--verbose] [-h|--help] [connect <number>]"
    echo -e ""
    echo -e "${BLUE}Options:${NC}"
    echo -e "  -v, --verbose   Show detailed messages"
    echo -e "  -h, --help      Show this help"
    echo -e "  connect <number> Connect directly to the server with the specified number"
}

# -----------------------------------------------------------------------------
# Function: validate_ip
# Description: Validates the format of an IP address.
# Arguments:
#   $1 - IP address to validate.
# Returns:
#   0 if the IP address is valid, 1 otherwise.
# -----------------------------------------------------------------------------
validate_ip() {
    local ip=$1
    if ! echo "$ip" | grep -E '^([0-9]{1,3}\.){3}[0-9]{1,3}$' > /dev/null; then
        echo -e "${RED}ERROR:${NC} The IP address $ip is not valid."
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Function: validate_port
# Description: Validates the port number.
# Arguments:
#   $1 - Port number to validate.
# Returns:
#   0 if the port is valid, 1 otherwise.
# -----------------------------------------------------------------------------
validate_port() {
    local port=$1
    if ! echo "$port" | grep -E '^[0-9]+$' > /dev/null || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
        echo -e "${RED}ERROR:${NC} The port $port is not valid."
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Function: build_ssh_command
# Description: Dynamically builds the SSH command.
# Arguments:
#   $1 - SSH key (optional).
#   $2 - Password (optional).
#   $3 - User.
#   $4 - IP address.
#   $5 - Port (optional).
# Returns:
#   Constructed SSH command.
# -----------------------------------------------------------------------------
build_ssh_command() {
    local key=$1
    local password=$2
    local user=$3
    local ip=$4
    local port=$5

    local ssh_cmd="ssh"
    if [ -n "$key" ]; then
        if [ ! -f "$key" ]; then
            echo -e "${RED}ERROR:${NC} The SSH key $key does not exist."
            return 1
        fi
        local key_perms
        key_perms=$(stat -c "%a" "$key")
        if [ "$key_perms" -ne 600 ]; then
            echo -e "${RED}ERROR:${NC} The SSH key $key must have 600 permissions."
            return 1
        fi
        ssh_cmd="$ssh_cmd -i \"$key\""
    elif [ -n "$password" ]; then
        if ! command -v sshpass &> /dev/null; then
            echo -e "${RED}ERROR:${NC} sshpass is not installed."
            return 1
        fi
        ssh_cmd="sshpass -p \"$password\" $ssh_cmd"
    fi
    ssh_cmd="$ssh_cmd $user@$ip"
    if [ -n "$port" ]; then
        ssh_cmd="$ssh_cmd -p $port"
    fi

    echo "$ssh_cmd"
    return 0
}

# -----------------------------------------------------------------------------
# Function: connect
# Description: Main function to connect to a server using SSH.
# -----------------------------------------------------------------------------
connect() {
    local config_file="${HOME}/.servers.json"
    local selected_server

    if [ -n "$1" ]; then
        selected_server=$(jq -r --argjson index "$1" '.servers[$index - 1].name' "$config_file")
        if [ -z "$selected_server" ]; then
            echo -e "${RED}ERROR:${NC} Invalid server number."
            exit 1
        fi
    else
        while true; do
            # Read the server configurations from the JSON file
            local servers=$(jq -r '.servers[] | "\(.name)"' "$config_file")

            if [ -z "$servers" ]; then
                echo -e "${RED}ERROR:${NC} No server configurations found in $config_file."
                exit 1
            fi

            # Display the server menu
            echo -e "${BLUE}Select a server to connect to (you can type to filter):${NC}"
            echo -e "${BLUE}----------------------------------------${NC}"
            local i=1
            local server_array=()
            while IFS= read -r server; do
                echo -e "${BLUE}| ${NC}$i) $server"
                server_array+=("$server")
                ((i++))
            done <<< "$servers"
            echo -e "${BLUE}----------------------------------------${NC}"

            # Read the user's selection
            read -p "Enter the number or part of the server name: " selection

            # Convert the user's selection to lowercase
            selection=$(echo "$selection" | tr '[:upper:]' '[:lower:]')

            # Filter servers if text is entered
            if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
                local filtered_servers=()
                local filtered_indices=()
                i=1
                for server in "${server_array[@]}"; do
                    # Convert the server name to lowercase for comparison
                    server_lower=$(echo "$server" | tr '[:upper:]' '[:lower:]')
                    if [[ "$server_lower" == *"$selection"* ]]; then
                        filtered_servers+=("$server")
                        filtered_indices+=("$i")
                    fi
                    ((i++))
                done

                if [ ${#filtered_servers[@]} -eq 0 ]; then
                    echo -e "${RED}ERROR:${NC} No servers found matching '$selection'."
                    continue
                elif [ ${#filtered_servers[@]} -eq 1 ]; then
                    selected_server="${filtered_servers[0]}"
                    break
                fi

                echo -e "${BLUE}Select a server from the filtered list:${NC}"
                echo -e "${BLUE}----------------------------------------${NC}"
                i=1
                for server in "${filtered_servers[@]}"; do
                    echo -e "${BLUE}| ${NC}$i) $server"
                    ((i++))
                done
                echo -e "${BLUE}----------------------------------------${NC}"

                read -p "Enter the server number: " selection
                if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt "${#filtered_servers[@]}" ]; then
                    echo -e "${RED}ERROR:${NC} Invalid selection."
                    continue
                fi

                selected_server="${filtered_servers[$((selection - 1))]}"
            else
                if [ "$selection" -lt 1 ] || [ "$selection" -gt "${#server_array[@]}" ]; then
                    echo -e "${RED}ERROR:${NC} Invalid selection."
                    continue
                fi

                selected_server="${server_array[$((selection - 1))]}"
            fi

            break
        done
    fi

    # Get the configuration of the selected server
    local user=$(jq -r --arg name "$selected_server" '.servers[] | select(.name == $name) | .user' "$config_file")
    local key=$(jq -r --arg name "$selected_server" '.servers[] | select(.name == $name) | .key' "$config_file")
    local password=$(jq -r --arg name "$selected_server" '.servers[] | select(.name == $name) | .password' "$config_file")
    local ip=$(jq -r --arg name "$selected_server" '.servers[] | select(.name == $name) | .ip' "$config_file")
    local port=$(jq -r --arg name "$selected_server" '.servers[] | select(.name == $name) | .port' "$config_file")

    # Display the details of the selected server in a box
    echo -e "${BLUE}INFO:${NC} The details of the selected server are:"
    echo -e "${BLUE}----------------------------------------${NC}"
    echo -e "${BLUE}| Name:       ${NC}$selected_server"
    echo -e "${BLUE}| User:       ${NC}$user"
    echo -e "${BLUE}| Key:        ${NC}$key"
    echo -e "${BLUE}| Password:   ${NC}$password"
    echo -e "${BLUE}| IP Address: ${NC}$ip"
    echo -e "${BLUE}| Port:       ${NC}$port"
    echo -e "${BLUE}----------------------------------------${NC}"

    # Validate parameters
    validate_ip "$ip" || { echo -e "${RED}ERROR:${NC} The IP address $ip is not valid."; exit 1; }
    validate_port "$port" || { echo -e "${RED}ERROR:${NC} The port $port is not valid."; exit 1; }

    # Build the SSH command
    ssh_cmd=$(build_ssh_command "$key" "$password" "$user" "$ip" "$port")
    if [ $? -ne 0 ]; then
        echo -e "${RED}ERROR:${NC} Could not build the SSH command."
        echo -e "${RED}Reason:${NC} $(build_ssh_command "$key" "$password" "$user" "$ip" "$port" 2>&1)"
        exit 1
    fi

    # Preview the SSH command
    log "${BLUE}INFO:${NC} Built SSH command: $ssh_cmd"

    # Test the connection and execute the SSH command
    echo -e "${BLUE}INFO:${NC} Testing the connection to the server..."
    if nc -z -w 5 "$ip" "$port"; then
        echo -e "${GREEN}INFO:${NC} Connection successful. Connecting..."
        eval "$ssh_cmd"
    else
        echo -e "${RED}ERROR:${NC} Could not connect to the server. Please check your internet connection and/or the server's IP address."
        exit 1
    fi
}

# Process command-line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -v|--verbose) VERBOSE=1 ;;
        -h|--help) show_help; exit 0 ;;
        -n|--number)
            shift
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                connect "$1"
                exit 0
            else
                echo -e "${RED}ERROR:${NC} Invalid server number."
                exit 1
            fi
            ;;
        *) echo -e "${RED}ERROR:${NC} Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

# Execute the function if the script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    connect
fi
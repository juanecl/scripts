#!/bin/bash

# Script to create a backup of a WordPress database
# Usage: ./dump-wp-db.sh [path_to_wp-config.php]
# If no path is provided, the script assumes it is in the root directory of a WordPress installation.

# Function to print error messages and exit
# Arguments:
#   $1 - The error message to print
# Example usage:
#   error_exit "An error occurred"
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Function to check if a command exists
# Arguments:
#   $1 - The command to check
# Example usage:
#   command_exists "mysqldump"
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to ensure required commands are available
# Arguments:
#   $@ - The list of commands to check
# Example usage:
#   check_required_commands mysqldump grep cut gzip
check_required_commands() {
    for cmd in "$@"; do
        command_exists "$cmd" || error_exit "$cmd is not installed. Please install it and try again."
    done
}

# Function to extract a value from wp-config.php
# Arguments:
#   $1 - The key to extract (e.g., "DB_USER")
#   $2 - The path to wp-config.php
# Example usage:
#   extract_wp_config_value "DB_USER" "./wp-config.php"
extract_wp_config_value() {
    local key=$1
    local wp_config_path=$2
    grep "$key" "$wp_config_path" | cut -d "'" -f 4 || error_exit "Failed to extract $key."
}

# Function to create a backup of the WordPress database
# Arguments:
#   $1 - The path to wp-config.php
# Example usage:
#   create_backup "./wp-config.php"
create_backup() {
    local wp_config_path=$1

    # Check if wp-config.php exists
    if [ ! -f "$wp_config_path" ]; then
        error_exit "wp-config.php not found at $wp_config_path. Please provide the correct path."
    fi

    # Extract database credentials from wp-config.php
    local db_user=$(extract_wp_config_value "DB_USER" "$wp_config_path")
    local db_password=$(extract_wp_config_value "DB_PASSWORD" "$wp_config_path")
    local db_host=$(extract_wp_config_value "DB_HOST" "$wp_config_path")
    local db_name=$(extract_wp_config_value "DB_NAME" "$wp_config_path")

    # Create a backup of the database
    local backup_file="backup_$(date +%F_%H-%M-%S).sql.gz"
    mysqldump --no-tablespaces -u "$db_user" -p"$db_password" -h "$db_host" "$db_name" | gzip > "$backup_file" || error_exit "Failed to create database backup."

    echo "Backup created successfully: $backup_file"
}

# Main function to execute the script logic
# Arguments:
#   $1 - The path to wp-config.php (optional)
# Example usage:
#   main "./wp-config.php"
main() {
    local wp_config_path="${1:-./wp-config.php}"

    # Ensure required commands are available
    check_required_commands mysqldump grep cut gzip

    # Check if wp-config.php exists in the current directory if no path is provided
    if [ ! -f "$wp_config_path" ]; then
        wp_config_path="./wp-config.php"
        if [ ! -f "$wp_config_path" ]; then
            error_exit "wp-config.php not found in the current directory or at the provided path. Please provide the correct path."
        fi
    fi

    # Create the backup
    create_backup "$wp_config_path"
}

# Execute the main function
main "$1"
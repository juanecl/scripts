#!/bin/bash

# -----------------------------------------------------------------------------
# WordPress Permissions Configuration Script
#
# This script changes ownership and sets the appropriate permissions for the
# files and directories of a WordPress installation. It is designed to be used
# with Bitnami installations, where the user and group are usually 'daemon'.
#
# Usage:
#   ./fix_permissions.sh --path <path> [--allow_uploads_to_group]
#
# Arguments:
#   --path <path>               Path to the WordPress installation directory.
#   --allow_uploads_to_group    Allow group write permissions for uploads, cache, plugins, and themes.
#
# Functions:
#   - change_ownership: Changes ownership of all files and directories.
#   - change_wp_config_ownership: Changes ownership of wp-config.php.
#   - change_wp_content_ownership: Changes ownership of the wp-content directory.
#   - set_file_permissions: Sets file permissions to 644.
#   - set_directory_permissions: Sets directory permissions to 755.
#   - secure_wp_config: Sets permissions to 600 for wp-config.php.
#   - secure_wp_content: Sets permissions to 755 for wp-content.
#   - set_uploads_cache_permissions: Sets permissions to 775 for uploads and cache.
#   - allow_plugins_themes_write: Allows write permissions for plugins and themes.
#   - secure_sensitive_files: Sets more restrictive permissions for sensitive files.
#   - verify_permissions: Verifies the applied permissions.
#
# -----------------------------------------------------------------------------

# Assign the Bitnami user and group (usually 'daemon')
USER="daemon"
GROUP="daemon"

# Function to change ownership of files
change_ownership() {
    echo "Changing ownership to 'daemon:daemon'..."
    sudo chown -R $USER:$GROUP "$1"
}

# Function to change ownership of wp-config.php
change_wp_config_ownership() {
    echo "Changing ownership to 'daemon:daemon' for wp-config.php..."
    sudo chown $USER:$GROUP "$1"
}

# Function to change ownership of the wp-content directory
change_wp_content_ownership() {
    echo "Changing ownership to 'daemon:daemon' for wp-content..."
    sudo chown -R $USER:$GROUP "$1"
}

# Function to set file permissions to 644
set_file_permissions() {
    echo "Setting file permissions to 644 in the WordPress directory..."
    sudo find "$1" -type f -exec chmod 644 {} \;
}

# Function to set directory permissions to 755
set_directory_permissions() {
    echo "Setting directory permissions to 755 in the WordPress directory..."
    sudo find "$1" -type d -exec chmod 755 {} \;
}

# Function to secure wp-config.php permissions
secure_wp_config() {
    echo "Ensuring wp-config.php has permissions 600..."
    sudo chmod 600 "$1"
}

# Function to secure wp-content directory permissions
secure_wp_content() {
    echo "Ensuring the wp-content directory has appropriate permissions..."
    sudo chmod -R 755 "$1"
}

# Function to set specific permissions for uploads and cache directories
set_uploads_cache_permissions() {
    local path="$1"
    local allow_group="$2"
    local perm=755
    if [[ "$allow_group" == true ]]; then
        perm=775
    fi
    echo "Setting permissions to $perm for directories in wp-content/uploads and wp-content/cache..."
    sudo find "$path/uploads" -type d -exec chmod $perm {} \;
    sudo find "$path/cache" -type d -exec chmod $perm {} \;
}

# Function to allow write permissions for plugins and themes directories
allow_plugins_themes_write() {
    local path="$1"
    local allow_group="$2"
    local perm=755
    if [[ "$allow_group" == true ]]; then
        perm=775
    fi
    echo "Setting permissions to $perm for directories in plugins and themes..."
    sudo find "$path/plugins" -type d -exec chmod $perm {} \;
    sudo find "$path/themes" -type d -exec chmod $perm {} \;
}

# Function to secure sensitive files permissions
secure_sensitive_files() {
    echo "Ensuring more restrictive permissions for sensitive files..."
    local sensitive_files=("$1/.htaccess" "$1/wp-config.php" "$1/php.ini" "$1/.user.ini")
    for file in "${sensitive_files[@]}"; do
        if [[ -f "$file" ]]; then
            echo "Setting permissions to 600 for $file..."
            sudo chmod 600 "$file"
        fi
    done
}

# Function to verify permissions
verify_permissions() {
    echo "Verifying the applied permissions..."
    ls -lR "$1" | grep -E "wp-config.php|uploads|cache|plugins|themes|.htaccess|php.ini|.user.ini"
}

# Main function
main() {
    local wordpress_path=""
    local allow_uploads_to_group=false

    while [[ "$#" -gt 0 ]]; do
        case $1 in
            --path)
                wordpress_path="$2"
                shift
                ;;
            --allow_uploads_to_group)
                allow_uploads_to_group=true
                ;;
            *)
                echo "Usage: $0 --path <path> [--allow_uploads_to_group]"
                exit 1
                ;;
        esac
        shift
    done

    if [[ -z "$wordpress_path" ]]; then
        echo "Error: The WordPress path is required."
        echo "Usage: $0 --path <path> [--allow_uploads_to_group]"
        exit 1
    fi

    change_ownership "$wordpress_path"
    change_wp_config_ownership "$wordpress_path/wp-config.php"
    change_wp_content_ownership "$wordpress_path/wp-content"
    set_file_permissions "$wordpress_path"
    set_directory_permissions "$wordpress_path"
    secure_wp_config "$wordpress_path/wp-config.php"
    secure_wp_content "$wordpress_path/wp-content"
    set_uploads_cache_permissions "$wordpress_path/wp-content" "$allow_uploads_to_group"
    allow_plugins_themes_write "$wordpress_path/wp-content" "$allow_uploads_to_group"
    secure_sensitive_files "$wordpress_path"
    verify_permissions "$wordpress_path"

    echo "WordPress permissions successfully assigned!"
}

main "$@"
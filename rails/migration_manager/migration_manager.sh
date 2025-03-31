#!/bin/bash

# -----------------------------------------------------------------------------
# Script: rails_migration_manager.sh
# Description: This script is a CLI tool to manage Rails database migrations.
#              It checks for Rails installation, verifies the database configuration file,
#              and runs pending migrations.
#
# Usage:
#   rails_migration_manager.sh [-h|--help] [-d|--directory <app_directory>]
#
# Arguments:
#   -d, --directory <app_directory>  Specify the Rails application directory. Defaults to the current directory.
#   -h, --help                       Display this help message.
#
# Requirements:
#   - ruby: Ruby must be installed.
#   - gem: RubyGems must be installed.
#   - rails: Rails must be installed.
#   - bundler: Bundler must be installed.
# -----------------------------------------------------------------------------

# Constants
SCRIPT_NAME=$(basename "$0")
RAILS_ENV="development" # Default Rails environment

# Function to display help message
show_help() {
    echo "Usage: $SCRIPT_NAME [-h|--help] [-d|--directory <app_directory>]"
    echo ""
    echo "Options:"
    echo "  -d, --directory <app_directory>  Specify the Rails application directory. Defaults to the current directory."
    echo "  -h, --help                       Display this help message."
}

# Function to check if a command is installed
check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it to proceed."
        return 1
    fi
    return 0
}

# Function to set Rails environment
set_rails_environment() {
    if [ -n "$RAILS_ENV" ]; then
        export RAILS_ENV="$RAILS_ENV"
        echo "INFO: Setting Rails environment to $RAILS_ENV"
    fi
}

# Function to check and install Rails
check_and_install_rails() {
    if ! check_command_installed "rails"; then
        echo "INFO: Rails is not installed. Installing now..."
        if ! gem install rails &> /dev/null; then
            echo "ERROR: Failed to install Rails. Please ensure RubyGems is properly configured."
            return 1
        fi
        echo "INFO: Rails installed successfully."
    fi
    return 0
}

# Function to check and install Bundler
check_and_install_bundler() {
    if ! check_command_installed "bundle"; then
        echo "INFO: Bundler is not installed. Installing now..."
        if ! gem install bundler &> /dev/null; then
            echo "ERROR: Failed to install Bundler. Please ensure RubyGems is properly configured."
            return 1
        fi
        echo "INFO: Bundler installed successfully."
    fi
    return 0
}

# Function to check database configuration file
check_db_config_file() {
    if [ ! -f "$APP_DIR/config/database.yml" ]; then
        echo "ERROR: Database configuration file not found. Ensure you are in the correct Rails application directory."
        return 1
    fi
    return 0
}

# Function to run database migrations
run_db_migrations() {
    echo "INFO: Checking for pending migrations..."
    if bundle exec rails db:migrate:status | grep -q 'down'; then
        echo "INFO: Pending migrations found. Running migrations..."
        if ! bundle exec rails db:migrate &> /dev/null; then
            echo "ERROR: Failed to run database migrations. Check the output for details."
            return 1
        fi
        echo "INFO: Database migrations completed successfully."
    else
        echo "INFO: No pending migrations."
    fi
    return 0
}

# Main function to manage Rails migrations
manage_rails_migrations() {
    # Set default application directory to current directory
    APP_DIR="${PWD}"

    # Parse command-line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--directory)
                APP_DIR="$2"
                shift
                ;;
            -h|--help)
                show_help
                return 0
                ;;
            *)
                echo "ERROR: Unknown parameter: $1"
                show_help
                return 1
                ;;
        esac
        shift
    done

    # Check if the specified directory exists
    if [ ! -d "$APP_DIR" ]; then
        echo "ERROR: Directory '$APP_DIR' not found."
        return 1
    fi

    # Check if Ruby is installed
    check_command_installed "ruby" || return 1

    # Check and install Bundler
    check_and_install_bundler || return 1

    # Change to the application directory
    cd "$APP_DIR" || {
        echo "ERROR: Could not change to directory '$APP_DIR'."
        return 1
    }

    # Set Rails environment
    set_rails_environment

    # Check and install Rails
    check_and_install_rails || return 1

    # Check database configuration file
    check_db_config_file || return 1

    # Run database migrations
    run_db_migrations || return 1

    echo "INFO: Rails migration management complete."
    return 0
}

# Run the main function
manage_rails_migrations "$@"
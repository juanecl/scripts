#!/bin/bash

# -----------------------------------------------------------------------------
# Script: check_git_access.sh
# Description: This script is a CLI tool to check if the current user has
#              permissions to access a Git repository (clone or pull).
#
# Usage:
#   check_git_access.sh <repository_url>
#
# Arguments:
#   <repository_url>  The URL of the Git repository to check.
#
# Returns:
#   0 if the user has access, 1 otherwise.
#
# Example:
#   check_git_access.sh https://github.com/user/repo.git
# -----------------------------------------------------------------------------

# Function to check if a command is installed
check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it to proceed." >&2
        return 1
    fi
    return 0
}

# Function to check Git permissions
check_git_permissions() {
    local repo_url="$1"

    # Check if git is installed
    check_command_installed "git" || return 1

    # Check if a repository URL is provided
    if [ -z "$repo_url" ]; then
        echo "ERROR: Repository URL is required." >&2
        return 1
    fi

    # Attempt to fetch the remote repository
    git ls-remote "$repo_url" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: You do not have permissions to clone or pull from the repository $repo_url." >&2
        return 1
    fi

    echo "INFO: Successfully validated permissions for $repo_url"
    return 0
}

# Check if a repository URL is provided
if [ -z "$1" ]; then
    echo "ERROR: Repository URL is required." >&2
    echo "Usage: $0 <repository_url>" >&2
    exit 1
fi

# Run the permission check
check_git_permissions "$1"

exit $?
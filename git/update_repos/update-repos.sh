#!/bin/bash

# -----------------------------------------------------------------------------
# Script: update_git_repos.sh
# Description: Updates multiple Git repositories by ensuring they are on 'main',
#              discarding local changes, and pulling latest updates.  Includes
#              permission checks before attempting updates.
# Author: Juan E. Chomon Del Campo
# Version: 1.3
# Usage: Run `./update_git_repos.sh` from the command line.
# -----------------------------------------------------------------------------

# Set script to exit on errors
set -e

# Define an array of Git repository paths
REPOSITORIES=(
    "/path/to/repo_1"
    "/path/to/repo_2"
    "/path/to/repo_3"
)

# Get current date for log files
CURRENT_DATE=$(date +"%Y%m%d")
DIFF_FILE="$HOME/diff-${CURRENT_DATE}.txt"

# Function to check if a command is installed
check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it to proceed."
        return 1
    fi
    return 0
}

# Function to check Git permissions
check_git_permissions() {
    # Repository URL (extracted from the remote origin)
    local repo_path="$1"
    local REPO_URL=$(git -C "$repo_path" config --get remote.origin.url)

    # Attempt to do a git ls-remote
    git ls-remote "$REPO_URL" &> /dev/null
    if [ $? -ne 0 ]; then
        echo "ERROR: You do not have permissions to clone or pull from the repository $REPO_URL."
        return 1
    fi
    return 0
}

# Function to update a Git repository
update_repository() {
    local repo_path="$1"

    echo "🔄 Updating repository at: $repo_path"

    # Check if the directory exists and is a valid Git repository
    if [ ! -d "$repo_path/.git" ]; then
        echo "⚠️  Warning: '$repo_path' is not a valid Git repository. Skipping..."
        return 1
    fi

    # Check Git permissions before proceeding
    if ! check_git_permissions "$repo_path"; then
        echo "⚠️  Skipping '$repo_path' due to insufficient permissions."
        return 1
    fi

    cd "$repo_path"

    # Get the current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

    # If not on main, switch to main
    if [ "$CURRENT_BRANCH" != "main" ]; then
        echo "🔀 Switching from '$CURRENT_BRANCH' to 'main'..."
        git checkout main || { echo "❌ Error: Could not switch to main. Skipping..."; return 1; }
    fi

    # Check for local changes
    if ! git diff --quiet || ! git diff --staged --quiet; then
        echo "⚠️  Local changes detected. Saving diff before resetting..."
        echo "🔍 Saving changes to ${DIFF_FILE}"

        # Append repo name to log
        echo "----------------------------------------" >> ${DIFF_FILE}
        echo "Changes in repository: $repo_path" >> ${DIFF_FILE}
        touch $DIFF_FILE
        git diff >> ${DIFF_FILE}
        git diff --staged >> ${DIFF_FILE}
    fi

    # Discard local changes
    echo "🛑 Discarding local changes..."
    git reset --hard

    # Fetch and pull the latest updates
    echo "📥 Pulling latest changes from origin/main..."
    git pull origin main --rebase

    echo "✅ Update completed for: $repo_path"
}

# Check if git is installed
check_command_installed "git" || exit 1

# Iterate over all repositories and update them
for repo in "${REPOSITORIES[@]}"; do
    update_repository "$repo"
    echo "-----------------------------------------"
done

echo "🚀 All repositories updated successfully!"
echo "🔍 Check ${DIFF_FILE} for saved local changes (if any)."
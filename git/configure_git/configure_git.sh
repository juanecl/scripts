#!/bin/bash

# -----------------------------------------------------------------------------
# Script: configure_git.sh
# Description: This script configures Git with user details, sets up SSH keys,
#              and configures the SSH agent. It is designed to be a CLI tool
#              for Linux and macOS systems.
#
# Usage:
#   configure_git.sh
#
# Requirements:
#   - git: Git must be installed.
#   - ssh-keygen: For generating SSH keys.
#   - ssh-agent: For managing SSH keys.
#   - ssh-add: For adding SSH keys to the agent.
# ----------------------------------------------------------------------------

DEFAULT_EDITOR="vim"
DEFAULT_PUSH_BEHAVIOR="simple"
DEFAULT_PULL_REBASE="true"
DEFAULT_BRANCH_NAME="main"

# Function to check if a command is installed
check_command_installed() {
    if ! command -v "$1" &> /dev/null; then
        echo "ERROR: $1 is not installed. Please install it to proceed."
        return 1
    fi
    return 0
}

# Function to configure Git user details
configure_git_user() {
    local config_type=$1 # "name" or "email"
    local prompt_message=$2
    local config_key="user.$config_type"

    # Get existing Git configuration
    local existing_value=$(git config --global --get "$config_key")

    if [[ -n "$existing_value" ]]; then
        echo "INFO: Your $config_type is $existing_value."
        read -p "Do you want to keep this value? (y/n): " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            read -p "Please enter your $config_type: " new_value
            git config --global "$config_key" "$new_value" &> /dev/null
            echo "INFO: Updated Git $config_type."
        fi
    else
        read -p "$prompt_message: " new_value
        git config --global "$config_key" "$new_value" &> /dev/null
        echo "INFO: Set Git $config_type."
    fi
}

# Function to generate SSH keys
generate_ssh_keys() {
    local key_name=$1
    if [[ -f ~/.ssh/"$key_name" && -f ~/.ssh/"$key_name".pub ]]; then
        echo "INFO: SSH keys $key_name and $key_name.pub already exist."
    else
        # Generate a new SSH key
        ssh-keygen -t rsa -b 4096 -C "$GIT_EMAIL" -f ~/.ssh/"$key_name" -N "" &> /dev/null
        echo "INFO: Generated new SSH key pair."
    fi
}

# Function to configure SSH agent
configure_ssh_agent() {
    local key_name=$1
    # Identify the operating system
    OS=$(uname)

    # Start the SSH authentication agent in the background
    if [ "$OS" = "Linux" ]; then
        eval "$(ssh-agent -s)" &> /dev/null
    elif [ "$OS" = "Darwin" ]; then
        eval "$(ssh-agent -s)"
        ssh-add -K ~/.ssh/"$key_name" &> /dev/null
    else
        echo "ERROR: Unsupported operating system."
        return 1
    fi

    # Check if the identity has already been added to the SSH agent
    if ssh-add -l | grep -q ~/.ssh/"$key_name" &> /dev/null; then
        echo "INFO: The identity has already been added to the SSH agent."
    else
        # Add the SSH key to the agent
        ssh-add ~/.ssh/"$key_name" &> /dev/null
        echo "INFO: Added SSH key to the SSH agent."
    fi
}

# Main function to configure Git
configure_git() {
    echo "INFO: Configuring Git..."

    # Check if Git is installed
    check_command_installed "git" || return 1
    check_command_installed "ssh-keygen" || return 1
    check_command_installed "ssh-agent" || return 1
    check_command_installed "ssh-add" || return 1

    # Ask the user for the key name
    read -p "Please enter the name you want to use for your SSH key (e.g., github, gitlab): " KEY_NAME

    # Configure Git user name and email
    configure_git_user "name" "Please enter your name"
    configure_git_user "email" "Please enter your email"

    # Additional Git configurations
    git config --global core.editor $DEFAULT_EDITOR # Set the default editor
    git config --global push.default $DEFAULT_PUSH_BEHAVIOR # Set the default behavior of 'git push'
    git config --global pull.rebase $DEFAULT_PULL_REBASE # Configure 'git pull' to use 'rebase' instead of 'merge'
    git config --global init.defaultBranch $DEFAULT_BRANCH_NAME # Set the default branch name when creating a new repository

    # Generate SSH keys
    generate_ssh_keys "$KEY_NAME"

    # Configure SSH agent
    configure_ssh_agent "$KEY_NAME"

    # Display the public key and instructions to add it to GitHub/GitLab
    echo "INFO: Your public SSH key is:"
    cat ~/.ssh/"$KEY_NAME".pub
    echo "INFO: Please add this SSH key to your GitHub account."
    echo "INFO: More information on adding SSH keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account"
    echo "INFO: Please add this SSH key to your Gitlab account."
    echo "INFO: More information on adding SSH keys: https://docs.gitlab.com/ee/user/ssh.html"

    echo "INFO: Git configuration complete."
}

# Run the configuration
configure_git
#!/bin/bash

# ###############################################################
# Description:
# ###############################################################
# This script automates the deployment, rollback, and management of Docker containers on Azure.
# It uses Azure CLI and Docker Compose to manage the deployment process.
#
# ###############################################################
# Arguments:
# ###############################################################
#   $1 - Action to perform: "release", "rollback", "reset", "stop", "start", "restart", "status", "logs", "list", or "help". Default is "release".
#   $2 - Docker image tag or container name for the "logs" action. If not provided, the result of get_last_tag is used.
#
# ###############################################################
# Environment variables:
# ###############################################################
#   PROJECT_HOME - Base directory for the script. You can put your own default value.
#   DEPLOY_FILE - Path to the Docker Compose configuration file. Default is "$PROJECT_HOME/docker-compose.yml".
#   ACR - Azure Container Registry name. You can put your own default value.
#   REPOSITORY - Repository name in the ACR. You can put your own default value.
#
# ###############################################################
# Example usage:
# ###############################################################
#   Release a specific version:
#     release 1.2.3
#
#   Release the latest version:
#     release
#
#   Rollback to the previous version:
#     rollback
#
#   Rollback to a specific version:
#     rollback 1.2.2
#
#   Stop the containers:
#     stop
#
#   Start the containers:
#     start
#
#   Restart the containers:
#     restart
#
#   View logs of a specific container:
#     logs web
#
#   List all available tags:
#     list
#
# ###############################################################
# Installation:
# ###############################################################
#   1. Install the required tools:
#      - Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
#      - Docker: https://docs.docker.com/get-docker/
#      - yamllint: pip install yamllint
#   2. Save this script to a file (e.g., deploy_acr_image) at the linux command directory /usr/local/bin.
#   3. Make the script executable: chmod +x /usr/local/bin/deploy_acr_image
#   4. Set the environment variables as needed.
#    For example, add the following lines to the ~/.bashrc file:
#      export PROJECT_HOME="/path/to/project"
#      export DEPLOY_FILE="$PROJECT_HOME/docker-compose.yml"
#      export ACR="ACR_NAME"
#      export REPOSITORY="REPOSITORY_NAME"
#   5. Run the script with the desired arguments.

CURRENT_HOME=${PROJECT_HOME:-"{DEPLOY_PATH}"}
COMPOSE_FILE=${DEPLOY_FILE:-"$CURRENT_HOME/docker-compose.yml"}
ACR=${ACR:-"{ACR_NAME}"}
REPOSITORY=${REPOSITORY:-"{REPOSITORY_NAME}"
REPOSITORY_URL="$ACR.azurecr.io/$REPOSITORY"
DEFAULT_RECIPIENT=${DEFAULT_RECIPIENT:-"{EMAIL}"}

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages with different levels
log_message() {
    local level=$1
    local message=$2
    case $level in
        INFO)
            echo -e "${BLUE}INFO${NC}: $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}SUCCESS${NC}: $message"
            ;;
        WARNING)
            echo -e "${YELLOW}WARNING${NC}: $message"
            ;;
        ERROR)
            echo -e "${RED}ERROR${NC}: $message"
            ;;
        *)
            echo -e "$message"
            ;;
    esac
}

# Function to show help message
show_help() {
    log_message INFO "Usage: <action> [argument]"
    log_message INFO "Actions:"
    log_message INFO "  release [tag]         Release a new version (default action). If no tag is provided, the latest tag with format [0-99].[0-99].[0-99] is used."
    log_message INFO "  rollback [tag]        Rollback to a previous version. If no tag is provided, the previous or latest tag with format [0-99].[0-99].[0-99] is used."
    log_message INFO "  stop                  Stop all containers."
    log_message INFO "  start                 Start all containers."
    log_message INFO "  restart               Restart all containers."
    log_message INFO "  status                Check the status of the containers."
    log_message INFO "  logs [name]           View logs of a specific container (\"web\", \"celery\", \"redis\")."
    log_message INFO "  tail [file] [lines]   View log files."
    log_message INFO "  list                  List all available tags."
    log_message INFO "  edit [file]           Edit any file in docker home path."
    log_message INFO "  help                  Show this help message."
}

# Main function to handle the deployment, rollback, and container management process
main() {
    # Set the action to the first argument or default to "release"
    local action=${1:-"release"}
    shift
    
    local arg=$1
    local arg2=$2
    local arg3=$3
    
    shift

    if [ "$action" == "help" ]; then
        show_help
        exit 0
    fi

    # If the action is "release", "rollback" or "list", perform initial validations and login
    if [[ "$action" =~ ^(release|rollback|list)$ ]]; then
        if [[ "$action" =~ ^(release|rollback)$ ]]; then
            # Validate that the Docker Compose file exists
            validate_file_exists "$COMPOSE_FILE"
            
            # Validate the syntax of the Docker Compose YAML file
            validate_yaml "$COMPOSE_FILE"
        fi

        # Check that required commands are available
        check_required_commands az docker sed
        
        # Log in to Azure
        azure_login
        
        # Log in to Azure Container Registry
        az acr login -n $ACR || exit 1
    fi

    # Handle different actions
    case "$action" in
        rollback)
            # Rollback to the previous version
            rollback "$arg"
            ;;
        stop)
            # Stop all containers
            stop_containers
            ;;
        start)
            # Start all containers
            start_containers
            ;;
        restart)
            # Restart all containers
            restart_containers
            ;;
        release)
            # Release a new version with the specified tag
            release "$arg"
            ;;
        logs)
            # View logs of a specific container
            view_logs "$arg"
            ;;
        edit)
            # Edit any file in docker home path
            edit "$arg"
            ;;
        tail)
            # View log files
            tail_logs "$arg" "$arg2" "$arg3"
            ;;
        status)
            # Check the status of the containers
            status
            ;;
        list)
            # List all available tags
            list_tags
            ;;
        *)
            # Print an error message for invalid actions
            log_message ERROR "Invalid action. Use 'help' for more information."
            exit 1
            ;;
    esac
    
}

# Function to validate if a file exists
# Usage: validate_file_exists <file>
# This function checks if the specified file exists. If not, it prints an error message and exits.
validate_file_exists() {
    local file=$1
    if [ ! -f "$file" ]; then
        log_message ERROR "The file $file does not exist."
        exit 1
    fi
}

# Function to check if the required commands are available
# Usage: check_required_commands <command1> <command2> ...
# This function checks if the specified commands are available in the system. If any command is missing, it prints an error message and exits.
check_required_commands() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            log_message ERROR "The command $cmd is not installed. Aborting."
            exit 1
        fi
    done
}

# Function to validate a YAML file using yamllint
# Usage: validate_yaml <file>
# This function validates the syntax of the specified YAML file using yamllint. If there are errors, it prints an error message and exits.
validate_yaml() {
    local file=$1
    log_message INFO "Validating $file..."
    yamllint "$file" || { log_message ERROR "Error in the YAML file. Please review the errors above."; exit 1; }
}

# Function to log in to Azure using device code authentication
# Usage: azure_login
# This function logs in to Azure using device code authentication. If the login fails, it prints an error message and exits.
azure_login() {
    log_message INFO "Logging in to Azure..."
    if ! az account show &> /dev/null; then
        az login --use-device-code || { log_message ERROR "Error logging in to Azure. Please try again."; exit 1; }
    else
        log_message SUCCESS "Already logged in to Azure."
    fi
}

# Function to get the latest tag with the format [0-99].[0-99].[0-99]
# Usage: get_last_tag
# This function retrieves the latest tag from the Azure Container Registry that matches the format [0-99].[0-99].[0-99]. If no valid tag is found, it prints an error message and exits.
get_last_tag() {
    local tags=$(az acr repository show-tags --name $ACR --repository $REPOSITORY --orderby time_desc --output tsv)
    local valid_tag=""
    while read -r tag; do
        if [[ $tag =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
            valid_tag=$tag
            break
        fi
    done <<< "$tags"
    if [ -z "$valid_tag" ]; then
        log_message ERROR "Unable to find tag with format [0-99].[0-99].[0-99]."
        exit 1
    fi
    echo "$valid_tag"
}

# Function to get the current image tag from the Docker Compose file
# Usage: get_current_tag
# This function extracts the current image tag from the Docker Compose file.
get_current_tag() {
    grep -oP 'image: "'$REPOSITORY_URL':\K[^"]+' "$COMPOSE_FILE" | awk '{print $1}'
}

# Function to change the image tag in the Docker Compose file
# Usage: change_image_tag <new_tag>
# This function updates the image tag in the Docker Compose file to the specified new tag.
change_image_tag() {
    local new_tag=$1
    log_message INFO "Changing the image tag in $COMPOSE_FILE to $new_tag..."
    sudo sed -i "s|image: \"$REPOSITORY_URL:.*\"|image: \"$REPOSITORY_URL:$new_tag\"|" "$COMPOSE_FILE"
}

# Function to start existing Docker containers
# Usage: start_containers
# This function starts the Docker containers defined in the Docker Compose file that are currently stopped.
start_containers() {
    log_message INFO "=============================="
    log_message INFO "Starting the containers defined in $COMPOSE_FILE..."
    log_message INFO "==============================\n"
    
    # Get the list of container IDs that are currently stopped
    local container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q --filter "status=exited")
    
    # Debugging: Print the container IDs
    log_message DEBUG "Container IDs: $container_ids"
    
    # Check if container_ids is empty
    if [ -z "$container_ids" ]; then
        log_message ERROR "No containers found to start."
        return 1
    fi
    
    # Loop through each container ID and start it
    for container_id in $container_ids; do
        log_message DEBUG "Processing container ID: $container_id"
        local container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\/\(.*\)/\1/')
        log_message WARNING "Starting container: $container_name"
        if docker start "$container_id"; then
            log_message SUCCESS "Container started successfully: $container_name"
        else
            log_message ERROR "Error starting container: $container_name"
            docker logs "$container_id"
        fi
        echo
    done

    # Check the status of the containers
    status
    log_message INFO "=============================="
    log_message INFO "All containers start process completed."
    log_message INFO "=============================="
}

# Function to stop existing Docker containers
# Usage: stop_containers
# This function stops the Docker containers defined in the Docker Compose file.
stop_containers() {
    log_message INFO "=============================="
    log_message INFO "Stopping the containers defined in $COMPOSE_FILE..."
    log_message INFO "==============================\n"
    
    # Get the list of all container IDs
    local container_ids=$(docker compose -f "$COMPOSE_FILE" ps -q)
    
    # Debugging: Print the container IDs
    log_message DEBUG "Container IDs: $container_ids"
    
    # Check if container_ids is empty
    if [ -z "$container_ids" ]; then
        log_message ERROR "No containers found to stop."
        return 1
    fi
    
    # Loop through each container ID and stop it
    for container_id in $container_ids; do
        log_message DEBUG "Processing container ID: $container_id"
        local container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/^\/\(.*\)/\1/')
        log_message WARNING "Stopping container: $container_name"
        if docker stop "$container_id"; then
            log_message SUCCESS "Container stopped successfully: $container_name"
        else
            log_message ERROR "Error stopping container: $container_name"
            docker logs "$container_id"
        fi
        echo
    done
    
    log_message INFO "=============================="
    log_message INFO "All containers stop process completed."
    log_message INFO "=============================="
}

# Function to restart Docker containers defined in a Docker Compose file
# Usage: restart_containers
# This function restarts the Docker containers defined in the Docker Compose file by stopping and then starting them.
restart_containers() {
    log_message INFO "Restarting the containers defined in $COMPOSE_FILE..."
    stop_containers
    start_containers
}

# Function to send email notifications
# Usage: send_email <subject> <message>
# This function sends an email with the specified subject and message.
send_email() {
    # Check if the 'mail' command is installed
    if ! command -v mail &> /dev/null; then
        echo "Error: 'mail' command is not installed. Please install it to send emails."
        return 1
    fi

    local subject=$1
    local message=$2
    local recipient=$DEFAULT_RECIPIENT  # Replace with your email

    echo -e "$message" | mail -s "$subject" "$recipient"
}
# Function to deploy a new version or rollback to a previous version
# Usage: deploy <action> <new_tag>
# This function handles the common steps for release and rollback processes by updating the image tag, stopping containers, pruning the Docker system, and starting the containers again.
deploy() {
    local action=$1
    local new_tag=$2
    local env=$(grep DJANGO_ENV $CURRENT_HOME/.env | cut -d '=' -f2)

    local subject="[$env] Docker Deployment Status"
    local message=""

    # Validate the new tag format
    if [[ ! $new_tag =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        message="Error: The new tag contains invalid characters. Only alphanumeric characters, dashes, and dots are allowed."
        log_message ERROR "$message"
        send_email "$subject - Failed" "$message"
        exit 1
    fi

    local current_tag=$(get_current_tag)

    # Save the current tag if it matches the version format and the action is "release"
    if [[ $action == "release" && $current_tag =~ ^[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}$ ]]; then
        echo $current_tag > $CURRENT_HOME/previous_tag.txt
    fi

    log_message INFO "Current tag: $current_tag"
    log_message INFO "New tag: $new_tag"

    # Change the image tag to the new tag
    change_image_tag "$new_tag"

    # Stop the containers defined in the Docker Compose file
    log_message INFO "Stopping the containers defined in $COMPOSE_FILE..."
    if ! docker compose -f "$COMPOSE_FILE" down; then
        message="Error stopping containers. Check Docker logs for more details."
        log_message ERROR "$message"
        send_email "$subject - Failed" "$message"
        exit 1
    fi

    # Remove all unused containers, images, networks, and volumes
    log_message INFO "Removing all unused containers, images, networks, and volumes..."
    if ! docker system prune -a -f; then
        message="Error pruning Docker system. Check Docker logs for more details."
        log_message ERROR "$message"
        send_email "$subject - Failed" "$message"
        exit 1
    fi

    # Create and start the containers defined in the Docker Compose file
    log_message INFO "Creating and starting the containers defined in $COMPOSE_FILE..."
    if ! docker compose -f "$COMPOSE_FILE" -p up -d; then
        message="Error starting containers. Check Docker logs for more details."
        log_message ERROR "$message"
        send_email "$subject - Failed" "$message"
        exit 1
    fi

    message="[$env] Deployment completed successfully. Tag: $new_tag"
    log_message INFO "$message"
    send_email "$subject - Success" "$message"

    logs web
}

# Function to release a new version
# Usage: release <new_tag>
# This function handles the release process by calling the deploy function with the "release" action.
release() {
    local new_tag=$1
    
    # If no new tag is provided get the last tag
    if [ -z "$new_tag" ]; then
        new_tag=$(get_last_tag)
    fi

    deploy "release" "$new_tag"
}

# Function to handle the rollback process
# Usage: rollback <new_tag>
# This function handles the rollback process by calling the deploy function with the "rollback" action.
rollback() {
    local new_tag=$1

    # If no new tag is provided, use the previous tag from the file or get the last tag from ACR
    if [ -z "$new_tag" ]; then
        if [ -f "$CURRENT_HOME/previous_tag.txt" ]; then
            new_tag=$(cat "$CURRENT_HOME/previous_tag.txt")
            log_message WARNING "Using previous tag for rollback: $new_tag"
        else
            new_tag=$(get_last_tag)
            log_message WARNING "Using last tag from ACR for rollback: $new_tag"
        fi
    fi

    deploy "rollback" "$new_tag"
}

# Function to display log files with optional filtering by log level
# If no log file is provided, it lists available log files in /var/log/ and allows the user to select one.
# If a log level is provided, it filters the log output by the specified level.
#
# Example usage:
#   tail_logs "" 50 "ERROR"    # Lists available log files and filters the selected log file by "ERROR" level
#   tail_logs "app.log" 50 ""  # Displays the specified log file without filtering
tail_logs() {
    # Capture arguments
    local log_file=$1
    local lines=${2:-50}
    local level=${3:-""}

    # If no log file is provided, list available log files and allow the user to select one
    if [ -z "$log_file" ]; then
        log_message WARNING "Warning: No log file provided. Please specify a log file."
        log_message INFO "Available log files:"
        # List available log files as a selection menu
        select log_file in /var/log/deploy_acr_image/*.log; do
            if [ -n "$log_file" ]; then
                break
            else
                log_message ERROR "Error: Invalid selection. Please select a valid log file."
            fi
        done
    fi

    # Check if a log level is provided and filter the log output accordingly
    if [ -n "$level" ]; then
        log_message INFO "Showing last $lines lines of log file: $log_file filtered by level: $level"
        tail -n $lines -f "$log_file" | grep -E "\[$level\]"
    else
        log_message INFO "Showing last $lines lines of log file: $log_file"
        tail -n $lines -f "$log_file"
    fi
}

# Function to get the Docker Compose project prefix
# This function lists running containers and extracts the common prefix used by Docker Compose.
# It handles errors and ensures that a valid prefix is returned.
#
# Example usage:
#   prefix=$(get_docker_compose_prefix)    # Retrieves the Docker Compose project prefix
get_docker_compose_prefix() {
    # List running containers and extract the prefix
    local prefix=$(docker ps --format '{{.Names}}' | grep -o '^[^_]*' | sort | uniq)

    # Check if a prefix was found
    if [ -z "$prefix" ]; then
        log_message ERROR "Error: No Docker Compose prefix found."
        return 1
    fi

    echo "$prefix"
}

# Function to check if a Docker container is running
# This function checks if a specified Docker container is running.
# It handles errors and ensures that the container is running before proceeding.
#
# Example usage:
#   check_container_running "container_name"    # Checks if the specified container is running
check_container_running() {
    local container_name=$1

    # Check if the container name is provided
    if [ -z "$container_name" ]; then
        log_message ERROR "Error: No container name provided. Please specify a container name."
        return 1
    fi

    # Check if the container is running
    if ! docker ps --format '{{.Names}}' | grep -q "^${container_name}$"; then
        log_message ERROR "Error: Container '$container_name' is not running."
        return 1
    fi

    log_message SUCCESS "Container '$container_name' is running."
}

# Function to view logs of a specific container
# Usage: view_logs <container_name>
# This function displays the logs of a specified container.
view_logs() {
    local container_name=$1

    # Check if a container name is provided
    if [ -z "$container_name" ]; then
        log_message ERROR "Error: No container name provided. Please specify a container name."
        exit 1
    fi

    # Example usage of the functions
    prefix=$(get_docker_compose_prefix)
    log_message INFO "Docker Compose prefix: $prefix"
    if [ $? -eq 0 ]; then
        log_message INFO "Docker Compose prefix: $prefix"
    else
        log_message ERROR "Failed to retrieve Docker Compose prefix."
        exit 1
    fi

    local full_container_name=$(docker ps --filter "name=$current_folder_name-$container_name-1" --format "{{.Names}}")
    if [ -z "$full_container_name" ]; then
        log_message ERROR "Container name cannot be determined. Please check the container name and try again."
        exit 1
    fi

    check_container_running "$full_container_name"
    if [ $? -eq 0 ]; then
        log_message SUCCESS "Container '$full_container_name' is running."
    else
        log_message ERROR "Container '$full_container_name' is not running."
        exit 1
    fi

    log_message INFO "Viewing logs for container: $full_container_name"
    # Display the logs of the specified container
    if ! docker logs -f "$full_container_name" --tail 100; then
        log_message ERROR "Error viewing logs for container $full_container_name. Check Docker logs for more details."
        exit 1
    fi
}

# Function to show the status of Docker containers
# This function displays the status of all Docker containers, highlighting those that are running or exited.
status() {
    log_message INFO "Showing status of all Docker containers..."
    echo "--------------------------------------------"

    # Get the list of all Docker containers with their ID, status, and names
    local containers=$(docker ps -a --format "{{.ID}} {{.Status}} {{.Names}}")

    # Iterate over each container and display its status
    while IFS= read -r container; do
        local container_id=$(echo $container | awk '{print $1}')
        local container_status=$(echo $container | awk '{print $2}')
        local container_name=$(echo $container | awk '{print $3}')

        # Highlight the container status based on whether it is running or exited
        if [[ $container_status == "Exited" ]]; then
            log_message ERROR "$container"
        elif [[ $container_status == "Up" ]]; then
            log_message SUCCESS "$container"
        else
            echo "$container"
        fi
    done <<< "$containers"

    echo "--------------------------------------------"

    # Get the list of all exited containers
    local exited_containers=$(docker ps -a --filter "status=exited" --format "{{.ID}}")
    for container in $exited_containers; do
        log_message ERROR "Container $container exited. Showing last 50 lines of logs:"
        # Display the last 10 lines of logs for each exited container
        docker logs --tail 50 "$container"
        echo "--------------------------------------------"
    done
}

edit() {
    local file=$CURRENT_HOME/$1

    if [ -z "$file" ]; then
        log_message ERROR "Error: No file provided. Please specify a file to edit."
        exit 1
    fi

    if [ ! -f "$file" ]; then
        log_message ERROR "Error: The file $file does not exist."
        exit 1
    fi

    log_message INFO "Editing file: $file"
    sudo nano "$file"
}

# Function to list all tags in the Azure Container Registry
# Usage: list_tags
# This function lists all the tags available in the Azure Container Registry for the specified repository.
list_tags() {
    log_message INFO "Listing all tags in the repository $REPOSITORY in ACR $ACR..."
    local tags=$(az acr repository show-tags --name $ACR --repository $REPOSITORY --orderby time_desc --output tsv)
    
    if [ -z "$tags" ]; then
        log_message ERROR "No tags found in the repository $REPOSITORY."
        exit 1
    fi

    log_message SUCCESS "Available tags:"
    echo "$tags"
}

# Execute the main function with the provided arguments
main "$@"
# Azure Docker Deployment Script

## Overview
The `deploy_acr_image` script automates the deployment, rollback, and management of Docker containers on Azure. It utilizes Azure CLI and Docker Compose to streamline the deployment process.

## Prerequisites
- **Azure CLI**: Install from [Microsoft Docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- **Docker**: Install from [Docker Docs](https://docs.docker.com/get-docker/)
- **YAML Linter (`yamllint`)**: Install via pip:
  ```bash
  pip install yamllint
  ```

## Installation and Setup
1. Save the script to a file:
   ```bash
   /usr/local/bin/deploy_acr_image
   ```
2. Grant execution permission:
   ```bash
   chmod +x /usr/local/bin/deploy_acr_image
   ```
3. Set up environment variables by adding them to `~/.bashrc`:
   ```bash
   export PROJECT_HOME="/path/to/project"
   export DEPLOY_FILE="$PROJECT_HOME/docker-compose.yml"
   export ACR="ACR_NAME"
   export REPOSITORY="REPOSITORY_NAME"
   ```
4. Reload environment variables:
   ```bash
   source ~/.bashrc
   ```

## Usage
```bash
deploy_acr_image <action> [arguments]
```

### Actions
- **`release [tag]`**: Deploys a new version. If no tag is provided, the latest tag is used.
- **`rollback [tag]`**: Rolls back to a previous version. If no tag is provided, the last tag is used.
- **`stop`**: Stops all running containers.
- **`start`**: Starts the stopped containers.
- **`restart`**: Restarts all containers.
- **`status`**: Displays the status of all containers.
- **`logs [container]`**: Shows logs of a specific container.
- **`list`**: Lists all available tags in the Azure Container Registry.
- **`help`**: Displays the help message.

### Examples
#### Release a specific version:
```bash
deploy_acr_image release 1.2.3
```
#### Rollback to the previous version:
```bash
deploy_acr_image rollback
```
#### Stop containers:
```bash
deploy_acr_image stop
```
#### View logs of a container:
```bash
deploy_acr_image logs web
```
#### List available tags:
```bash
deploy_acr_image list
```

## Features
- **Manages Docker deployments on Azure**
- **Handles rollback functionality**
- **Validates Docker Compose files**
- **Integrates with Azure CLI for authentication**
- **Includes logging and debugging tools**

## Troubleshooting
- Ensure you are logged into Azure:
  ```bash
  az login --use-device-code
  ```
- Verify that `mysqldump`, `grep`, `cut`, and `gzip` are installed.
- If `deploy_acr_image list` returns empty, verify the ACR and repository settings.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
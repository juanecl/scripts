# Check Git Access Script

## Overview
The `check_git_access.sh` script is a CLI tool designed to verify if the current user has permission to access a specified Git repository (clone or pull).

## Prerequisites
- **Git**: Ensure Git is installed on your system.
- **Network Access**: The script must be able to reach the repository URL.

## Installation and Setup
1. Download or create the script.
2. Grant execution permission:
   ```bash
   chmod +x check_git_access.sh
   ```
3. Run the script with the Git repository URL:
   ```bash
   ./check_git_access.sh <repository_url>
   ```

## Usage
```
check_git_access.sh <repository_url>
```

### Arguments
- **`<repository_url>`**: The URL of the Git repository to check.

### Examples
#### Checking access to a public repository:
```bash
./check_git_access.sh https://github.com/user/repo.git
```

#### Checking access to a private repository:
```bash
./check_git_access.sh git@github.com:user/repo.git
```

## Features
- **Checks for Git installation**: Ensures Git is installed before proceeding.
- **Validates repository URL**: Ensures a repository URL is provided.
- **Attempts remote access**: Uses `git ls-remote` to check access permissions.

## Return Codes
- **0**: The user has access to the repository.
- **1**: The user does not have permission or an error occurred.

## Logs and Troubleshooting
- If access is denied, verify:
  - The repository URL is correct.
  - Authentication credentials (SSH key or Git credentials) are properly configured.
  - Run manually:
    ```bash
    git ls-remote <repository_url>
    ```
  - Check network connectivity.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl


# Update Multiple Git Repositories Script

## Overview
The `update_git_repos.sh` script automates the process of updating multiple Git repositories. It ensures each repository is on the `main` branch, discards local changes, and pulls the latest updates. The script includes permission checks before attempting updates.

## Prerequisites
- **Git**: Ensure Git is installed on your system.
- **Proper Git Permissions**: The user must have `pull` access to the repositories.
- **Configured Remote Repositories**: Each repository must have a properly configured `origin` remote.

## Installation and Setup
1. Download or create the script.
2. Grant execution permission:
   ```bash
   chmod +x update_git_repos.sh
   ```
3. Update the `REPOSITORIES` array inside the script with the paths to your local Git repositories.
4. Run the script:
   ```bash
   ./update_git_repos.sh
   ```

## Usage
```
update_git_repos.sh
```

## Features
- **Validates Repositories**: Checks if the provided paths are valid Git repositories.
- **Permission Check**: Verifies whether the user has access to pull from the remote repository.
- **Ensures `main` Branch**: Automatically switches to `main` if on a different branch.
- **Saves Local Changes**: If uncommitted changes are detected, they are saved in a backup file before being reset.
- **Performs Hard Reset**: Ensures a clean working directory by discarding all local changes.
- **Fetches and Rebases Latest Changes**: Uses `git pull --rebase` to get the latest updates.

## Logs and Troubleshooting
- If a repository has local changes, the script saves them to a backup file:
  ```bash
  ~/diff-YYYYMMDD.txt
  ```
- If a repository does not have proper permissions, it will be skipped with a warning.
- Ensure all repositories in the `REPOSITORIES` array exist and are correctly configured.

## Example Output
```
🔄 Updating repository at: /path/to/repo_1
🔀 Switching from 'feature-branch' to 'main'...
🛑 Discarding local changes...
📥 Pulling latest changes from origin/main...
✅ Update completed for: /path/to/repo_1
-----------------------------------------
🚀 All repositories updated successfully!
🔍 Check ~/diff-YYYYMMDD.txt for saved local changes (if any).
```

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
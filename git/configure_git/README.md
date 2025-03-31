# Git Configuration Script

## Overview
The `configure_git.sh` script is a CLI tool designed to automate the configuration of Git, including setting up user details, generating SSH keys, and configuring the SSH agent. It is intended for use on Linux and macOS systems.

## Prerequisites
- **Git**: Ensure Git is installed on your system.
- **SSH tools**: The script requires `ssh-keygen`, `ssh-agent`, and `ssh-add`.

## Installation and Setup
1. Download or create the script.
2. Grant execution permission:
   ```bash
   chmod +x configure_git.sh
   ```
3. Run the script:
   ```bash
   ./configure_git.sh
   ```

## Features
- **Configures Git user details**: Prompts for and sets the global Git user name and email.
- **Sets Git defaults**:
  - Default editor: `vim`
  - Default push behavior: `simple`
  - Default pull strategy: `rebase`
  - Default branch name: `main`
- **Generates an SSH key**: If a key does not already exist, it generates a new key pair.
- **Configures the SSH agent**: Adds the SSH key to the agent for authentication.
- **Displays SSH public key**: Provides instructions to add the SSH key to GitHub and GitLab.

## Usage
Simply run the script and follow the prompts:
```bash
./configure_git.sh
```

## Logs and Troubleshooting
- If a required command is missing, the script will notify you and exit.
- If SSH keys already exist, it will notify you and avoid overwriting them.
- To manually check the SSH configuration:
  ```bash
  ssh -T git@github.com
  ```

## References
- **GitHub SSH Key Setup**: [GitHub Docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)
- **GitLab SSH Key Setup**: [GitLab Docs](https://docs.gitlab.com/ee/user/ssh.html)

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
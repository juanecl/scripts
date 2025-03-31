# AWS EC2 Instance Stopper Script

## Overview
The `stop_instance.sh` script is a command-line tool for stopping an AWS EC2 instance. It ensures that AWS CLI is installed and configured, verifies the instance existence, and monitors its status until it stops. If the instance does not stop within 10 minutes, an email notification is sent.

## Prerequisites
- **AWS CLI** must be installed and configured with valid credentials.
- **Mail client** (e.g., `mailx`) must be installed for email notifications.

## Installation
### Linux & macOS
1. Install AWS CLI:
   ```bash
   sudo apt install awscli -y   # Debian-based systems
   sudo yum install awscli -y   # RHEL-based systems
   brew install awscli          # macOS
   ```
2. Configure AWS CLI:
   ```bash
   aws configure
   ```
   Provide AWS Access Key, Secret Access Key, Default Region, and Output Format.

3. Install a mail client if not installed:
   ```bash
   sudo apt install mailutils -y    # Debian-based systems
   sudo yum install mailx -y        # RHEL-based systems
   brew install mailutils           # macOS
   ```

4. Grant execution permission:
   ```bash
   chmod +x stop_instance.sh
   ```

## Usage
```bash
./stop_instance.sh <instance-id> <region> <tag>
```

### Arguments
- **`<instance-id>`**: The ID of the EC2 instance to stop.
- **`<region>`**: The AWS region where the EC2 instance is located.
- **`<tag>`**: A tag to identify the instance in logs and notifications.

### Examples
#### Stop an instance with a specific ID:
```bash
./stop_instance.sh i-1234567890abcdef us-east-1 MyInstance
```

## Features
- **Pre-Execution Validations:**
  - Checks if AWS CLI is installed.
  - Ensures AWS CLI is configured.
  - Validates provided arguments.
  - Confirms the existence of the EC2 instance.
- **Instance Monitoring:**
  - Waits up to 10 minutes for the instance to stop.
  - Sends an email notification upon successful stop.
  - If the instance does not stop within 10 minutes, sends an alert email.

## Troubleshooting
- **AWS CLI not found:** Install AWS CLI and configure credentials.
- **Instance not found:** Verify the provided instance ID and region.
- **Email not sent:** Ensure the `mail` command is installed and properly configured.
- **Permission Denied:** Ensure the script has execution permissions using:
  ```bash
  chmod +x stop_instance.sh
  ```

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
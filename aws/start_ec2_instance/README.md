# AWS EC2 Instance Start Script

## Overview
The `start_instance.sh` script automates the process of starting an AWS EC2 instance, ensuring that:
- The AWS CLI is installed and configured.
- The specified EC2 instance exists.
- The instance starts successfully within 10 minutes.
- An email notification is sent upon successful startup or failure.

## Prerequisites
- AWS CLI must be installed and configured with appropriate permissions.
- A valid AWS IAM user with `ec2:StartInstances` and `ec2:DescribeInstances` permissions.
- Mail client (`mail` command) should be configured for email notifications.

## Installation
1. Install AWS CLI if not already installed:
   ```sh
   sudo apt install awscli -y  # Debian-based systems
   sudo yum install awscli -y  # RHEL-based systems
   brew install awscli         # macOS
   ```
2. Configure AWS CLI:
   ```sh
   aws configure
   ```
3. Ensure `mail` command is available:
   ```sh
   sudo apt install mailutils -y  # Debian-based systems
   sudo yum install mailx -y      # RHEL-based systems
   brew install mailutils         # macOS (via Homebrew)
   ```

## Usage
```sh
./start_instance.sh <instance-id> <region> <tag>
```

### Arguments
| Argument     | Description |
|-------------|-------------|
| `<instance-id>` | The ID of the EC2 instance to start. |
| `<region>` | The AWS region where the EC2 instance is located. |
| `<tag>` | A tag to identify the instance in logs and notifications. |

### Example
```sh
./start_instance.sh i-1234567890abcdef us-east-1 MyInstance
```

## Features
- **AWS CLI Check:** Ensures AWS CLI is installed.
- **AWS CLI Configuration Check:** Validates credentials.
- **Instance Validation:** Checks if the instance exists.
- **Automatic Instance Start:** Initiates instance startup.
- **Status Monitoring:** Waits up to 10 minutes for the instance to transition to `running` state.
- **Email Notification:** Sends an email upon success or failure.

## Troubleshooting
- **AWS CLI Not Installed:**
  ```sh
  aws: command not found
  ```
  **Solution:** Install AWS CLI using package manager (see Installation section).

- **AWS CLI Not Configured:**
  ```sh
  ERROR: AWS CLI is not configured
  ```
  **Solution:** Run `aws configure` and enter AWS credentials.

- **Invalid Instance ID or Region:**
  ```sh
  ERROR: No EC2 instance found with the provided ID
  ```
  **Solution:** Verify the instance ID and AWS region.

- **Instance Not Starting:**
  If the instance does not start within 10 minutes, an email alert is sent.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
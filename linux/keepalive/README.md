# Keepalive Service Script

## Overview
The Keepalive Service script is a Bash script designed to ensure that a specified service remains running. If the service stops, the script attempts to restart it and sends an email notification about the status.

## Prerequisites
- A Linux system with `systemctl` support (e.g., Ubuntu, CentOS, RHEL).
- A configured mail package to send notifications.
- Execution permissions for the script (`chmod +x keepalive.sh`).

## Installation and Setup
1. Download or create the `keepalive.sh` script.
2. Grant execution permission:
   ```bash
   chmod +x keepalive.sh
   ```
3. Ensure the mail package is installed and properly configured for email notifications.

## Usage
Run the script manually by executing:
```bash
./keepalive.sh [service name]
```

### Example
To monitor and restart the Apache service:
```bash
./keepalive.sh apache2.service
```

### Setting Up a Cron Job
To automate the execution of the script every 5 minutes, add the following entry to the crontab:
```bash
*/5 * * * * /bin/sh /home/keepalive.sh apache2.service
```
This ensures that the script continuously monitors the service and takes action if it stops.

## How It Works
1. The script checks the status of the specified service.
2. If the service is inactive, it logs the event and sends an email notification.
3. The script attempts to restart the service.
4. If successful, another email is sent confirming the restoration.
5. If the restart fails, an alert email is sent.

## Configuration
- **MAIL**: Set the recipient email address for notifications.
- **CLIENT**: Customize the client name for logging and emails.
- **HOSTNAME**: Automatically retrieved from the system hostname.

## Logs
The script logs activity using the `log_message` function. Logs are typically found in:
```bash
/var/log/cron
```

## Troubleshooting
- Ensure the script has execution permissions.
- Verify that the mail package is installed and properly configured.
- Check the system logs and the output of:
  ```bash
  systemctl status [service name]
  ```
- Test the script manually before adding it to cron.

## License
This script is provided as-is without any warranties. Use it at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Enmail**: hola@juane.cl

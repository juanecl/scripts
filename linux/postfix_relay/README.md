# Postfix SMTP Relay Configuration Script

## Overview
This Bash script automates the configuration of Postfix as an SMTP relay using a specified relay server (SMTP server). It ensures that all necessary dependencies are installed, configures Postfix settings, sets up authentication credentials, and sends a test email to verify the configuration.

## Prerequisites
- A Linux-based system with `yum` as the package manager (e.g., CentOS, RHEL).
- Root or sudo privileges.
- A valid SMTP relay server with authentication credentials.

## Installation
1. Download the script to your server.
2. Ensure the script has execution permissions:
   ```bash
   chmod +x script.sh
   ```
3. Run the script:
   ```bash
   ./script.sh
   ```

## Script Functionality
The script performs the following steps:
1. Prompts the user to enter SMTP relay details (or loads them from environment variables).
2. Checks and installs necessary dependencies (`postfix`, `cyrus-sasl-plain`, `mailx`).
3. Configures Postfix with the specified relay server.
4. Sets up authentication credentials securely.
5. Restarts and enables the Postfix service.
6. Sends a test email to verify the configuration.

## Environment Variables
Instead of entering details manually, you can set environment variables before running the script:
```bash
export RECIPIENT="recipient@example.com"
export RELAY_SERVER="smtp.example.com"
export RELAY_PORT="587"
export SMTP_USER="user@example.com"
export SMTP_PASSWORD="yourpassword"
export MYHOSTNAME="www.yourdomain.com"
export MYORIGIN="yourdomain.com"
./script.sh
```

## Configuration Files Modified
- `/etc/postfix/main.cf` (Postfix main configuration file)
- `/etc/postfix/sasl_passwd` (SMTP authentication credentials, stored securely)

## Testing the Configuration
After running the script, the test email should be delivered to the specified recipient. If you do not receive it, check the following:
- Postfix logs: `/var/log/maillog`
- System logs: `journalctl -u postfix`
- Verify that the SMTP credentials are correct.
- Ensure that the SMTP relay server allows your connection.

## Security Considerations
- The SMTP password is stored in `/etc/postfix/sasl_passwd`, which is set to be readable only by root and the Postfix user.
- Using environment variables for credentials is recommended for security instead of entering them interactively.
- TLS is enabled for secure email transmission.

## Troubleshooting
If you encounter issues, try the following:
- Restart the Postfix service manually:
  ```bash
  systemctl restart postfix
  ```
- Re-run the script with correct details.
- Check firewall and SELinux settings that may block SMTP traffic.
- Ensure the SMTP relay server is reachable from your system.

## License
This script is provided as-is without any warranties. Use it at your own risk.

## Author
- Juan Enrique Chomon Del Campo
- Contact: hola@juane.cl


# Network Monitoring and Alert Script

## Overview
This Bash script monitors network connections on a Linux or macOS system. It checks for active processes that establish network connections and performs the following checks:

- Reverse DNS Lookup: Identifies the hostname associated with an IP address.
- WHOIS Lookup: Retrieves registration details for a domain or IP.
- Email Alerting: Sends an alert if a process connects to an unknown or suspicious address.

The script runs in a loop, checking the network every 5 minutes.

## Features
- Detects network connections from active processes.
- Performs reverse DNS lookups.
- Retrieves WHOIS information for remote addresses.
- Sends email alerts for unidentified or suspicious connections.
- Checks for required dependencies and suggests installation if missing.
- Supports both Linux and macOS.

## Prerequisites
Ensure the following utilities are installed on your system:

- `mailx` (for sending email alerts)
- `whois` (for domain/IP lookups)
- `dig` (for DNS resolution)
- `ps`, `awk`, `sed` (for parsing system processes)
- `ss` (for checking network connections on Linux) or `netstat` (for macOS)

To install these utilities:

- **Debian/Ubuntu**: `sudo apt-get install mailutils whois dnsutils`
- **CentOS/RHEL**: `sudo yum install mailx whois bind-utils`
- **macOS**: `brew install mailutils whois bind`

## Configuration
Edit the script to configure email alert settings:

```bash
SMTP_SERVER="smtp-mail.outlook.com"
SMTP_PORT=587
SMTP_USER="your-email@outlook.com"
SMTP_PASS="your-app-password"
ALERT_EMAIL="your-email@outlook.com"
```

> It is recommended to use an **app password** instead of your actual email password for security reasons.

## Usage
Run the script using:

```bash
chmod +x network_monitor.sh
./network_monitor.sh
```

The script will continuously monitor network connections and send alerts if suspicious activity is detected.

## How It Works
1. The script retrieves active network connections.
2. It checks whether each remote address is an IP or a domain.
3. If the address is an IP:
   - A reverse DNS lookup is performed.
   - If no hostname is found, an alert is sent.
4. If the address is a domain:
   - A WHOIS lookup is performed.
   - If no WHOIS information is found, an alert is sent.
5. The script loops every 5 minutes to recheck network activity.

## Example Output
```
Alert: firefox (PID: 1234) connected to 192.168.1.100 (no DNS resolution)
Alert: unknown_process (PID: 5678) connected to malicious-domain.com (no WHOIS information)
```

## Troubleshooting
If you encounter errors:
- Ensure all required utilities are installed.
- Verify SMTP settings for email alerts.
- Check logs for failed DNS or WHOIS lookups.

## License
This script is based on a PowerShell script by [Hamdi Bouasker](https://github.com/hamdi-bouasker) and is released under an open-source license. Feel free to modify and improve it.

## Disclaimer
Use this script responsibly. It is intended for security monitoring, and misuse may lead to unintended network disruptions.

## Author
# Translated from a powershell script made by https://github.com/hamdi-bouasker


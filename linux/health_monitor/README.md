# System Resource Monitor

## Overview
This Python script monitors system resources, including CPU, disk, RAM, network I/O, swap usage, and active connections. It sends alerts to Slack if any resource usage exceeds predefined thresholds.

## Prerequisites
- Python 3.x installed.
- `psutil` and `requests` Python packages installed:
  ```bash
  pip install psutil requests
  ```
- A valid Slack webhook URL stored in the environment variable `SLACK_WEBHOOK_URL`.

## Installation and Setup
1. Clone or download the script.
2. Set up environment variables:
   ```bash
   export SLACK_WEBHOOK_URL='https://hooks.slack.com/services/YOUR/WEBHOOK/URL'
   export CPU_THRESHOLD=80
   export DISK_THRESHOLD=90
   export RAM_THRESHOLD=90
   export SWAP_THRESHOLD=90
   export NET_CONNECTIONS_THRESHOLD=100
   export CHECK_INTERVAL=5
   ```
3. Run the script:
   ```bash
   python monitor.py
   ```
4. Run in silent mode (no console output):
   ```bash
   python monitor.py --silent
   ```

## Features
- **Monitors:**
  - CPU usage and temperature
  - Disk usage and I/O
  - RAM and swap usage
  - Network I/O and active connections
  - Running processes
- **Alerts:**
  - Sends a Slack notification when resource usage exceeds thresholds.
- **Silent Mode:**
  - Run with `--silent` to suppress console output.

## Configuration
- **Thresholds**
  - Default values are set via environment variables. Update them as needed.
- **Slack Integration**
  - Set `SLACK_WEBHOOK_URL` to enable Slack notifications.

## Logs and Troubleshooting
- The script outputs real-time resource usage to the console.
- If Slack alerts are not working, ensure:
  - The webhook URL is correctly set.
  - Network connectivity allows outbound requests.
  - The `requests` package is installed.
- Check system logs for resource constraints.

## License
This script is provided as-is without any warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl


# Cloudflare DNS Backup Script

## Overview
This script automates the backup of DNS records from Cloudflare. It retrieves all zones associated with your Cloudflare account, exports their DNS records, compresses the backup, and emails it to you.

## Prerequisites
- **Cloudflare API Key**: Must be a valid token with permissions to read DNS records.
- **curl** and **jq**: Used to make API calls and parse JSON.
- **mail**: For sending the backup as an attachment.

## Installation
1. Ensure the following are installed:
   ```bash
   sudo apt install curl jq mailutils -y    # Debian/Ubuntu
   sudo yum install curl jq mailx -y        # RHEL/CentOS
   brew install curl jq                    # macOS
   ```
2. Save the script to a file, e.g. `backup_dns.sh`.
3. Make it executable:
   ```bash
   chmod +x backup_dns.sh
   ```

## Usage
```
./backup_dns.sh
```

### Environment Variables
- **`DEFAULT_EMAIL`**: Email address to receive the backup.
- **`CLOUDFLARE_APIKEY`**: Your Cloudflare API key.

### Example
```bash
DEFAULT_EMAIL="user@example.com" CLOUDFLARE_APIKEY="your_api_key" ./backup_dns.sh
```

## Script Flow
1. **Fetch Zones**: Retrieves the list of all zones using the Cloudflare API.
2. **Export DNS Records**: Iterates through each zone and exports its DNS records.
3. **Tar & Gzip**: Compresses all DNS records into a single `.tar.gz` file.
4. **Send Email**: Emails the compressed file to the configured address.
5. **Cleanup**: Removes temporary files and folders.

## Customization
- **`HOST`**: The Cloudflare API endpoint.
- **`DATE`**: Used to generate the filename timestamp.
- **`DNS_FOLDER`**: Directory to store temporary DNS records before compression.

## Troubleshooting
- **Access Denied**: Check that your Cloudflare API key is correct and has the necessary permissions.
- **Mail Not Sending**: Verify `mail` is installed and configured for your system.
- **Permissions**: The script uses `sudo` for commands like `curl`, `tar`, and `rm`. Adjust as needed if your environment doesn't require `sudo`.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
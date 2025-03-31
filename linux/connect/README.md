# SSH Connection Manager Script

## Overview
The `connect.sh` script provides a streamlined way to connect to remote servers via SSH using configurations stored in a JSON file (`.servers.json`). It allows users to select servers interactively or connect directly by specifying a server number.

## Prerequisites
- **jq**: For parsing JSON configuration.
- **nc (Netcat)**: For testing server connectivity.
- **sshpass** (optional): Required if password authentication is used.

## Installation and Setup
### Linux (Debian/RHEL-based Systems)
1. Install required dependencies:
   ```bash
   sudo apt install jq netcat sshpass -y  # Debian-based systems
   sudo yum install jq nc sshpass -y     # RHEL-based systems
   ```

### macOS
1. Install required dependencies using Homebrew:
   ```bash
   brew install jq netcat
   ```
   - `sshpass` is not available in Homebrew for security reasons. If needed, install manually:
     ```bash
     brew install hudochenkov/sshpass/sshpass
     ```

2. Save your server configurations in `~/.servers.json`:
   ```json
   {
       "servers": [
           {
               "name": "server1",
               "user": "user1",
               "key": "~/.ssh/id_rsa",
               "ip": "192.168.1.1",
               "port": 22
           },
           {
               "name": "server2",
               "user": "user2",
               "password": "mypassword",
               "ip": "192.168.1.2",
               "port": 2222
           }
       ]
   }
   ```

3. Grant execution permission:
   ```bash
   chmod +x connect.sh
   ```

## Usage
```
./connect.sh [-v|--verbose] [-h|--help] [-n|--number <server_number>]
```

### Options
- **`-v, --verbose`**: Show detailed log messages.
- **`-h, --help`**: Display help information.
- **`-n, --number <server_number>`**: Connect directly to a server using its assigned number.

### Examples
#### Connect to a server interactively:
```bash
./connect.sh
```
#### Connect directly to the first server in the list:
```bash
./connect.sh -n 1
```
#### Enable verbose logging while connecting:
```bash
./connect.sh -v
```

## Features
- **Interactive Selection**: Allows users to filter and select servers dynamically.
- **Direct Connection**: Supports quick access via `-n <server_number>`.
- **SSH Key or Password Authentication**: Automatically determines the appropriate authentication method.
- **Pre-Connection Validation**: Checks IP format, port validity, and SSH key permissions.
- **Connection Testing**: Uses `nc` to verify server accessibility before attempting SSH login.

## Troubleshooting
- **Ensure `jq` is installed**: If the script fails to parse `.servers.json`, install `jq`:
  ```bash
  sudo apt install jq -y  # Linux
  brew install jq         # macOS
  ```
- **Invalid IP or Port**: Check your configuration in `~/.servers.json`.
- **SSH Key Issues**: Ensure the SSH key exists and has correct permissions (`chmod 600 <key>`).
- **Cannot Connect**: Use `nc -z <ip> <port>` to check connectivity manually.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
# Add Domain to /etc/hosts Script

## Overview
The `add_to_hosts.sh` script automates the process of adding a domain to the `/etc/hosts` file under the “Automatic Insertions” section. After adding the domain, it optionally clears the DNS cache if the relevant commands are available (useful on macOS).

## Usage
```bash
./add_to_hosts.sh <domain>
```

### Example
```bash
./add_to_hosts.sh example.local
```

## How It Works
1. **Domain Check**: Verifies if the domain already exists in `/etc/hosts`.
2. **Automatic Insertions Section**: If it doesn’t exist, the script inserts the domain under the `# Automatic Insertions` section. If that section doesn’t exist, the script creates it.
3. **DNS Cache Clearing**: Tries to clear the DNS cache using `killall -HUP mDNSResponder`. This is primarily useful for macOS systems.

## Requirements
- **sudo access**: The script needs root privileges to modify `/etc/hosts`.
- **macOS or Linux**:
  - On macOS, it attempts to clear the DNS cache.
  - On Linux, clearing the DNS cache is not guaranteed (the command may not exist).

## Functions
- **`is_domain_in_hosts`**: Checks if a domain already exists in `/etc/hosts`.
- **`add_domain_to_hosts`**: Inserts the domain under the `# Automatic Insertions` section.
- **`clear_dns_cache`**: Clears the DNS cache on compatible systems (macOS).
- **`add_to_hosts_table`**: Main function to add the domain to `/etc/hosts`.

## Notes
- If the DNS cache clearing step fails, you may need to manually clear the cache depending on your distribution.
- The script uses `awk` to insert the domain. Adjust the logic if you have a customized `/etc/hosts` structure.

## Troubleshooting
- **Permission Denied**: Ensure you run the script with sufficient privileges (`sudo`).
- **Cache Not Clearing**: If the script prints a warning about not clearing DNS cache, you may need to use an OS-specific command manually (e.g., `dscacheutil -flushcache` on older macOS versions, or restarting DNS services on Linux).

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
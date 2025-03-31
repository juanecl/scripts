# WordPress Permissions Checker

## Overview
The `check_wp_permissions.sh` script scans a WordPress installation to ensure files and directories meet recommended permission settings. It also looks for potentially malicious or suspicious files, logs the results in `check_wp_permissions.log`, and provides guidance on how to correct any issues.

## Usage
```bash
./check_wp_permissions.sh --path <path> [--help]
```

### Options
- **`--path <path>`**: The absolute path to the WordPress installation.
- **`--help`**: Displays script usage information and exits.

### Example
```bash
./check_wp_permissions.sh --path /var/www/html/wordpress
```

## Features
1. **Permission Checks**:
   - **Directories**: Checks if directories have `755` permissions.
   - **Files**: Checks if files have `644` permissions.
   - **`wp-config.php`**: Ensures more restrictive settings (`440` or `400`).
   - **Uploads Directory**: Ensures uploads have `775` for directories and `664` for files.
2. **Suspicious File Detection**:
   - Looks for random file names (high entropy/consonant ratio), unusual permissions or file size, recent modifications, or common malicious patterns.
3. **Detailed Log Output**:
   - Creates `check_wp_permissions.log` with a summary of incorrect permissions and suspicious files.
4. **Recommendations**:
   - Provides commands to correct improper file or directory permissions.

## Installation and Setup
1. **Ensure `bash` is available** (default on most Linux systems).
2. **Optional**: Make script executable:
   ```bash
   chmod +x check_wp_permissions.sh
   ```
3. **Run**:
   ```bash
   ./check_wp_permissions.sh --path <wordpress_path>
   ```

## Troubleshooting
- **Permission Denied**:
  - Run the script with `sudo` if you do not have the necessary permissions to read or execute files.
- **wp-config.php Not Found**:
  - Verify that the specified path is correct.
- **Suspicious Files**:
  - Investigate any flagged files to ensure they are legitimate or remove/quarantine if malicious.

## Notes
- The script counts the number of files or directories not matching recommended permissions.
- Suspicious file detection uses heuristics—some legitimate files may be flagged.
- Adjust the thresholds (e.g., file size, entropy) in the script if needed.

## Example Output
```
Checking permissions in the WordPress installation at /var/www/html/wordpress...
    ❌  /var/www/html/wordpress/index.php has permissions 644 (expected: 600)
    ❌  /var/www/html/wordpress/wp-content/plugins has permissions 775 (expected: 755)
⚠️  Potentially dangerous file found: /var/www/html/wordpress/wp-content/unused.php (reasons: suspicious content)
Permissions check summary:
Files and directories with incorrect permissions: 2
Potentially dangerous files: 1
----------------------------------------
To correct incorrect permissions, you can use the following commands:
For directories: find <path> -type d -exec chmod 755 {} \;
For files: find <path> -type f -exec chmod 644 {} \;
For wp-config.php: chmod 440 <path>/wp-config.php
```

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
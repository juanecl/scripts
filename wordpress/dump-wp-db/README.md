# WordPress Database Backup Script

## Overview
The `dump-wp-db.sh` script automates the process of creating a backup of a WordPress database. It extracts database credentials from the `wp-config.php` file and uses `mysqldump` to generate a compressed backup file.

## Prerequisites
- **MySQL/MariaDB**: Ensure `mysqldump` is installed.
- **Required Utilities**: `grep`, `cut`, and `gzip` must be available.
- **WordPress Installation**: The script requires access to `wp-config.php`.

## Installation and Setup
1. Download or create the script.
2. Grant execution permission:
   ```bash
   chmod +x dump-wp-db.sh
   ```
3. Run the script with the appropriate options:
   ```bash
   ./dump-wp-db.sh [path_to_wp-config.php]
   ```

## Usage
```
dump-wp-db.sh [path_to_wp-config.php]
```

### Arguments
- **`[path_to_wp-config.php]`** (Optional): The full path to `wp-config.php`. Defaults to `./wp-config.php`.

### Examples
#### Backup using default location:
```bash
./dump-wp-db.sh
```
#### Backup specifying the path to `wp-config.php`:
```bash
./dump-wp-db.sh /var/www/html/wp-config.php
```

## Features
- **Extracts credentials securely**: Reads database credentials from `wp-config.php`.
- **Checks required dependencies**: Ensures `mysqldump`, `grep`, `cut`, and `gzip` are installed.
- **Creates a timestamped backup**: The backup file is compressed and named using the format `backup_YYYY-MM-DD_HH-MM-SS.sql.gz`.
- **Error handling**: Provides informative error messages if dependencies are missing or if `wp-config.php` is not found.

## Logs and Troubleshooting
- If the script fails to create a backup, check:
  - That `mysqldump` is installed and accessible.
  - That the `wp-config.php` path is correct.
  - Run the script manually with debugging enabled:
    ```bash
    bash -x dump-wp-db.sh
    ```

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
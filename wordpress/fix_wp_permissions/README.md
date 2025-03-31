# WordPress Permissions Configuration Script

## Overview
The `fix_permissions.sh` script sets correct file and directory permissions for a WordPress installation running under the Bitnami stack, typically using the user/group `daemon:daemon`. It secures sensitive files and optionally allows group write access to certain directories for easier uploads and updates.

## Usage
```bash
./fix_permissions.sh --path <path> [--allow_uploads_to_group]
```

### Example
```bash
./fix_permissions.sh --path /opt/bitnami/wordpress --allow_uploads_to_group
```

### Arguments
- **`--path <path>`**: The absolute path to the WordPress installation directory.
- **`--allow_uploads_to_group`**: Enable group write permissions for specific directories such as `uploads`, `cache`, `plugins`, and `themes`.

## Prerequisites
- **sudo Access**: Modifying file ownership and permissions requires elevated privileges.
- **Bitnami WordPress**: The default user and group are `daemon:daemon`. Adjust if your environment differs.

## Functions
1. **`change_ownership`**: Recursively sets `daemon:daemon` ownership on all files.
2. **`change_wp_config_ownership`**: Ensures `wp-config.php` has correct ownership.
3. **`change_wp_content_ownership`**: Ensures `wp-content` directory is owned by `daemon:daemon`.
4. **`set_file_permissions`**: Sets all files to `644`.
5. **`set_directory_permissions`**: Sets all directories to `755`.
6. **`secure_wp_config`**: Restricts `wp-config.php` to `600`.
7. **`secure_wp_content`**: Ensures `wp-content` directories have at most `755`.
8. **`set_uploads_cache_permissions`**: Sets permissions in `wp-content/uploads` and `wp-content/cache` to `775` if group write is allowed, else `755`.
9. **`allow_plugins_themes_write`**: Allows group write (`775`) for plugins and themes if `--allow_uploads_to_group` is used.
10. **`secure_sensitive_files`**: Restricts other sensitive files (like `.htaccess`, `php.ini`) to `600` if they exist.
11. **`verify_permissions`**: Outputs a listing of key files/directories for review.

## Steps
1. **Set Script Permissions**: Make the script executable:
   ```bash
   chmod +x fix_permissions.sh
   ```
2. **Run with `sudo`**: The script modifies ownership/permissions, so elevated privileges are typically required.
3. **Verify**: After running, confirm your site is functioning and that uploads or plugin installations succeed.

## Examples
1. **Basic Permissions Setup**:
   ```bash
   sudo ./fix_permissions.sh --path /opt/bitnami/wordpress
   ```
2. **Enable Group Writing for Uploads/Plugins**:
   ```bash
   sudo ./fix_permissions.sh --path /opt/bitnami/wordpress --allow_uploads_to_group
   ```

## Troubleshooting
- **Permission Denied**:
  - Ensure you are running the script as root or with `sudo`.
- **Ownership Mismatch**:
  - If you are not using the Bitnami stack, replace `daemon:daemon` with your server’s web user/group.
- **File Already Has Insecure Permissions**:
  - The script secures `wp-config.php` and `.htaccess` to `600`. If your WordPress requires different settings, adjust accordingly.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl


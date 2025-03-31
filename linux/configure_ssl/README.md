# Nginx Local Domain with Self-Signed SSL Configuration Script

## Overview
This Bash script automates the setup of a local domain with Nginx and a self-signed SSL certificate on macOS. It installs required dependencies, generates a self-signed SSL certificate, configures Nginx, and adds the domain to the system.

## Prerequisites
- A macOS system with Homebrew installed.
- Administrator privileges to modify system files.
- OpenSSL and Nginx installed via Homebrew.

## Installation and Setup
1. Download or create the `nginx_ssl_setup.sh` script.
2. Grant execution permission:
   ```bash
   chmod +x nginx_ssl_setup.sh
   ```
3. Run the script with a domain name and optional port:
   ```bash
   ./nginx_ssl_setup.sh [domain] [port]
   ```
   Example:
   ```bash
   ./nginx_ssl_setup.sh example.dev 8000
   ```
   If no domain or port is specified, it defaults to `local.dev` and `8000`.

## Script Functionality
1. **Installs Dependencies**: Ensures Homebrew, OpenSSL, and Nginx are installed.
2. **Configures OpenSSL**: Sets up an OpenSSL configuration file with Subject Alternative Names (SAN).
3. **Generates SSL Certificate**: Creates a self-signed SSL certificate for the given domain.
4. **Creates dhparam.pem**: Generates a Diffie-Hellman parameter file for enhanced security.
5. **Configures Nginx**: Sets up a virtual host with SSL support.
6. **Modifies `/etc/hosts`**: Adds the domain to resolve locally.
7. **Restarts Nginx**: Validates and restarts Nginx to apply changes.
8. **Adds SSL to macOS Trust Store**: Ensures the certificate is trusted by macOS.

## Configuration Files Modified
- **`/etc/ssl/openssl.cnf`**: Modified to include SAN for the specified domain.
- **`/opt/homebrew/etc/nginx/servers/[domain].conf`**: Nginx virtual host configuration.
- **`/etc/hosts`**: Adds an entry to point the domain to `127.0.0.1`.

## Logs
- The script outputs status messages during execution.
- Check Nginx logs for errors:
  ```bash
  sudo nginx -t
  sudo tail -f /opt/homebrew/var/log/nginx/access.log
  ```

## Troubleshooting
- Ensure Nginx is installed and running:
  ```bash
  brew install nginx
  sudo nginx
  ```
- Verify the SSL certificate exists in `/usr/local/etc/ssl/certs/`.
- Check if the domain is correctly mapped in `/etc/hosts`.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juane Chomon**
- **Version**: 2.0
- **Date**: March 9, 2024


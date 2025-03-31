#!/bin/bash
set -e

# ====================================================================================
# Script to configure a local domain in nginx with self-signed SSL on macOS
# ====================================================================================
# Author: Juane Chomon
# Date: 09/03/2024
# Version: 2.0
# Description:
# This script installs dependencies (Homebrew, nginx, OpenSSL), configures a virtual host
# in nginx, generates a self-signed SSL certificate, and adds the domain to the local system.
# ====================================================================================

# Global variables
CERT_DIR="/usr/local/etc/ssl"
NGINX_CONF_DIR="/opt/homebrew/etc/nginx/servers"
OPENSSL_CNF="/etc/ssl/openssl.cnf"
DHPARAM_FILE="$CERT_DIR/certs/dhparam.pem"

# Utility functions (Single Responsibility Principle - SRP)
# ====================================================================================
# Function to print messages in colors
# Arguments:
#   $1 - The color code (e.g., 32 for green, 33 for yellow)
#   $2 - The message to print
# Example usage:
#   print_message "32" "Success message"
function print_message() {
    local color=$1
    local message=$2
    echo -e "\033[1;${color}m${message}\033[0m"
}

# Function to check and install dependencies (Open/Closed Principle - OCP)
# Arguments:
#   $1 - The name of the dependency (e.g., "nginx")
#   $2 - The command to check (e.g., "nginx")
# Example usage:
#   ensure_dependency_installed "nginx" "nginx"
function ensure_dependency_installed() {
    local name=$1
    local command=$2
    if ! command -v "$command" &>/dev/null; then
        print_message "33" "$name is not installed. Installing..."
        brew install "$name"
        print_message "32" "$name installed successfully.\n"
    else
        print_message "32" "$name is already installed.\n"
    fi
}

# Function to prepare the OpenSSL configuration file
# Arguments:
#   $1 - The domain name (e.g., "example.dev")
# Example usage:
#   configure_openssl_cnf "example.dev"
function configure_openssl_cnf() {
    local domain=$1

    if [ -f "$OPENSSL_CNF" ]; then
        print_message "33" "Removing existing openssl.cnf in /etc/ssl..."
        sudo rm -f "$OPENSSL_CNF"
    fi

    print_message "33" "Copying openssl.cnf to /etc/ssl..."
    sudo cp /System/Library/OpenSSL/openssl.cnf "$OPENSSL_CNF"

    print_message "33" "Configuring SAN in openssl.cnf for domain $domain..."
    sudo tee -a "$OPENSSL_CNF" >/dev/null <<EOF

[ v3_req ]
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = $domain
DNS.2 = www.$domain
EOF

    print_message "32" "openssl.cnf configured successfully.\n"
}

# Function to create a self-signed SSL certificate
# Arguments:
#   $1 - The domain name (e.g., "example.dev")
# Example usage:
#   create_ssl_certificate "example.dev"
function create_ssl_certificate() {
    local domain=$1
    if [ ! -f "$CERT_DIR/private/$domain.key" ]; then
        print_message "33" "Generating SSL certificate for $domain..."
        sudo openssl req -x509 -nodes -days 365 -newkey rsa:4096 -config "$OPENSSL_CNF" \
            -extensions v3_req -subj "/C=CL/ST=RM/O=Local/CN=$domain" \
            -keyout "$CERT_DIR/private/$domain.key" -out "$CERT_DIR/certs/$domain.crt"
        print_message "32" "SSL certificate generated successfully.\n"
    else
        print_message "32" "SSL certificate already exists.\n"
    fi
}

# Function to create a dhparam.pem file
# Example usage:
#   create_dhparam_file
function create_dhparam_file() {
    if [ ! -f "$DHPARAM_FILE" ]; then
        print_message "33" "Generating dhparam.pem (this may take a few minutes)..."
        sudo openssl dhparam -out "$DHPARAM_FILE" 4096
        print_message "32" "dhparam.pem generated successfully.\n"
    else
        print_message "32" "dhparam.pem already exists.\n"
    fi
}

# Function to configure a virtual host in nginx (Liskov Substitution Principle - LSP)
# Arguments:
#   $1 - The domain name (e.g., "example.dev")
#   $2 - The port number (e.g., 8000)
# Example usage:
#   configure_nginx_vhost "example.dev" 8000
function configure_nginx_vhost() {
    local domain=$1
    local port=$2
    local vhost_file="$NGINX_CONF_DIR/$domain.conf"

    if [ ! -f "$vhost_file" ]; then
        print_message "33" "Creating nginx configuration for $domain..."
        sudo tee "$vhost_file" >/dev/null <<EOF
server {
    listen 80;
    server_name $domain www.$domain;
    return 301 https://\$host\$request_uri;
}

server {
    listen 443 ssl;
    server_name $domain www.$domain;

    ssl_certificate $CERT_DIR/certs/$domain.crt;
    ssl_certificate_key $CERT_DIR/private/$domain.key;
    ssl_dhparam $DHPARAM_FILE;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    location / {
        proxy_pass http://localhost:$port;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_page 500 502 503 504 /50x.html;
    location = /50x.html {
        root /usr/share/nginx/html;
    }
}
EOF
        print_message "32" "nginx configuration created successfully.\n"
    else
        print_message "32" "nginx configuration already exists.\n"
    fi
}

# Function to add the domain to the /etc/hosts file
# Arguments:
#   $1 - The domain name (e.g., "example.dev")
# Example usage:
#   add_domain_to_hosts "example.dev"
function add_domain_to_hosts() {
    local domain=$1
    if ! grep -q "$domain" /etc/hosts; then
        print_message "33" "Adding $domain to /etc/hosts..."
        echo "127.0.0.1 $domain www.$domain" | sudo tee -a /etc/hosts >/dev/null
        print_message "32" "$domain added to /etc/hosts.\n"
    else
        print_message "32" "$domain is already in /etc/hosts.\n"
    fi
}

# Function to restart nginx and validate configuration
# Example usage:
#   restart_nginx
function restart_nginx() {
    print_message "33" "Validating nginx configuration..."
    if sudo nginx -t &>/dev/null; then
        print_message "32" "nginx configuration is valid.\n"
        print_message "33" "Restarting nginx..."
        if [ -f /opt/homebrew/var/run/nginx.pid ]; then
            sudo nginx -s reload
        else
            sudo nginx
        fi
        print_message "32" "nginx restarted successfully.\n"
    else
        print_message "31" "Error in nginx configuration. Check the logs."
        exit 1
    fi
}

# Function to add the SSL certificate to the macOS trust store
# Arguments:
#   $1 - The domain name (e.g., "example.dev")
# Example usage:
#   add_ssl_to_macos_trust "example.dev"
function add_ssl_to_macos_trust() {
    local domain=$1
    if ! security find-certificate -c "$domain" &>/dev/null; then
        print_message "33" "Adding SSL certificate for $domain to macOS trust store..."
        sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_DIR/certs/$domain.crt"
        print_message "32" "SSL certificate added to macOS trust store.\n"
    else
        print_message "32" "SSL certificate already exists in macOS trust store.\n"
    fi
}

# Main program (Dependency Inversion Principle - DIP)
# Arguments:
#   $1 - The domain name (default: "local.dev")
#   $2 - The port number (default: 8000)
# Example usage:
#   main "example.dev" 8000
function main() {
    local domain=${1:-"local.dev"}
    local port=${2:-8000}

    # Create necessary directories
    sudo mkdir -p "$CERT_DIR"/{certs,private} "$NGINX_CONF_DIR"

    # Check and install dependencies
    ensure_dependency_installed "Homebrew" "brew"
    ensure_dependency_installed "nginx" "nginx"
    ensure_dependency_installed "OpenSSL" "openssl"

    # Configure files and generate certificates
    configure_openssl_cnf "$domain"
    create_ssl_certificate "$domain"
    create_dhparam_file

    # Configure nginx and restart
    configure_nginx_vhost "$domain" "$port"
    add_domain_to_hosts "$domain"
    restart_nginx

    # Add SSL to macOS trust store
    add_ssl_to_macos_trust "$domain"

    # Final message
    print_message "32" "SSL configuration for $domain completed successfully."
}

# Execute main program
main "$@"
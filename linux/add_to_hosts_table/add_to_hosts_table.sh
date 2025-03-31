#!/bin/bash

# -----------------------------------------------------------------------------
# Script: add_to_hosts.sh
# Description: This script adds a specified domain to the /etc/hosts file under
#              the "Automatic Insertions" section. It also clears the DNS cache
#              if applicable.
#
# Usage:
#   ./add_to_hosts.sh <domain>
#
# Arguments:
#   <domain>  The domain to add to the /etc/hosts file.
#
# Example:
#   ./add_to_hosts.sh example.local
#
# Functions:
#   - is_domain_in_hosts: Checks if a domain is already in the /etc/hosts file.
#   - add_domain_to_hosts: Adds a domain to the "Automatic Insertions" section
#                          of the /etc/hosts file.
#   - clear_dns_cache: Clears the DNS cache (only for compatible systems).
#   - add_to_hosts_table: Main function to add a domain to the /etc/hosts file.
#
# -----------------------------------------------------------------------------

# Path to the /etc/hosts file
HOSTS_FILE="/etc/hosts"

# -----------------------------------------------------------------------------
# Function: is_domain_in_hosts
# Description: Checks if a domain is already in the /etc/hosts file.
# Arguments:
#   $1 - The domain to check.
# Returns:
#   0 if the domain is found, 1 otherwise.
# -----------------------------------------------------------------------------
is_domain_in_hosts() {
    local domain=$1
    grep -q "$domain" "$HOSTS_FILE"
}

# -----------------------------------------------------------------------------
# Function: add_domain_to_hosts
# Description: Adds a domain to the "Automatic Insertions" section of the
#              /etc/hosts file.
# Arguments:
#   $1 - The domain to add.
# -----------------------------------------------------------------------------
add_domain_to_hosts() {
    local domain=$1
    if ! grep -q "# Automatic Insertions" "$HOSTS_FILE"; then
        echo -e "# Automatic Insertions\n127.0.0.1 $domain" | sudo tee -a "$HOSTS_FILE" > /dev/null
    else
        sudo awk -v domain="$domain" '/# Automatic Insertions/ {print; print "127.0.0.1 " domain; next} 1' "$HOSTS_FILE" > temp && sudo mv temp "$HOSTS_FILE"
    fi
}

# -----------------------------------------------------------------------------
# Function: clear_dns_cache
# Description: Clears the DNS cache (only for compatible systems).
# -----------------------------------------------------------------------------
clear_dns_cache() {
    if command -v killall > /dev/null && command -v mDNSResponder > /dev/null; then
        sudo killall -HUP mDNSResponder
        echo "The DNS cache has been cleared."
    else
        echo "Warning: Could not clear the DNS cache (command not available)."
    fi
}

# -----------------------------------------------------------------------------
# Function: add_to_hosts_table
# Description: Main function to add a domain to the /etc/hosts file.
# Arguments:
#   $1 - The domain to add.
# -----------------------------------------------------------------------------
add_to_hosts_table() {
    local domain=$1

    # Validate input
    if [ -z "$domain" ]; then
        echo "Usage: $0 <domain>"
        echo "Example: $0 example.local"
        exit 1
    fi

    # Check if the domain already exists
    if is_domain_in_hosts "$domain"; then
        echo "The domain $domain is already in $HOSTS_FILE."
    else
        # Add domain and clear cache
        add_domain_to_hosts "$domain"
        clear_dns_cache
        echo "The domain $domain has been added to $HOSTS_FILE."
    fi
}

# Execute only if invoked directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    add_to_hosts_table "$1"
fi
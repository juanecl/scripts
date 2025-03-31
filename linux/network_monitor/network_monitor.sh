#!/bin/bash
# Translated from a powershell script made by https://github.com/hamdi-bouasker

# Email configuration
SMTP_SERVER="smtp-mail.outlook.com"
SMTP_PORT=587
SMTP_USER="your-email@outlook.com"
SMTP_PASS="your-app-password"
ALERT_EMAIL="your-email@outlook.com"

# Function to send alert email
# This function sends an email alert with the specified message.
# Arguments:
#   $1: The message to include in the email body.
send_alert() {
    local message="$1"
    echo -e "Subject: Alert: Suspicious connection detected\n\n$message" | mailx -s "Alert: Suspicious connection detected" "$ALERT_EMAIL"
    echo "$message"
}

# Function to perform WHOIS lookup
# This function performs a WHOIS lookup for the given address.
# Arguments:
#   $1: The address to perform the WHOIS lookup on.
# Returns:
#   The result of the WHOIS lookup.
whois_lookup() {
    local address="$1"
    result=$(whois "$address" 2>/dev/null)
    echo "$result"
}

# Function to perform reverse DNS lookup
# This function performs a reverse DNS lookup for the given IP address.
# Arguments:
#   $1: The IP address to perform the reverse DNS lookup on.
# Returns:
#   The hostname if the lookup is successful, or an error message if it fails.
reverse_dns() {
    local ip="$1"
    hostname=$(dig -x "$ip" +short 2>/dev/null)
    if [ -z "$hostname" ]; then
        echo "Reverse DNS lookup failed for $ip"
    else
        echo "$hostname"
    fi
}

# Function to check network connections
# This function checks current network connections and sends alerts for suspicious connections.
# It performs reverse DNS and WHOIS lookups to gather information about remote addresses.
check_network() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        connections=$(netstat -anp tcp | awk 'NR>2 {print $5,$9}' | sed 's/.*pid=//g' | awk '{print $1, $2}')
    else
        connections=$(ss -tunp | awk 'NR>1 {print $5,$7}' | sed 's/.*pid=//g' | awk '{print $1, $2}')
    fi

    while IFS= read -r line; do
        remote_address=$(echo "$line" | awk '{print $1}' | cut -d':' -f1)
        process_info=$(echo "$line" | awk '{print $2}')
        process_name=$(ps -p "$process_info" -o comm= 2>/dev/null)

        if [[ "$remote_address" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
            dns_result=$(reverse_dns "$remote_address")
            if [[ "$dns_result" == *"Reverse DNS lookup failed"* ]]; then
                send_alert "Alert: $process_name (PID: $process_info) connected to $remote_address (no DNS resolution)"
            fi
        else
            whois_result=$(whois_lookup "$remote_address")
            if [[ -z "$whois_result" ]]; then
                send_alert "Alert: $process_name (PID: $process_info) connected to $remote_address (no WHOIS information)"
            fi
        fi
    done <<< "$connections"
}

# Function to check if required commands are available
# This function checks if the specified commands are available in the system.
# Arguments:
#   $@: The list of commands to check.
# Exits the script if any command is not found.
check_required_commands() {
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: $cmd is not installed. Please install it and try again."
            suggest_installation "$cmd"
            exit 1
        fi
    done
}

# Function to suggest installation commands based on the OS
# This function suggests installation commands for missing dependencies.
# Arguments:
#   $1: The command that is missing.
suggest_installation() {
    local cmd="$1"
    echo "To install $cmd, you can use the following commands based on your OS:"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            echo "Ubuntu/Debian: sudo apt-get install $cmd"
        elif command -v yum &> /dev/null; then
            echo "CentOS/RHEL: sudo yum install $cmd"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        if [[ "$cmd" == "ss" ]]; then
            echo "macOS: ss is not available. Using netstat instead."
        else
            echo "macOS: brew install $cmd"
        fi
    fi
}

# Main function to run the network check
# This function runs the network check in a loop, checking every 5 minutes.
main() {
    check_required_commands mailx whois dig ps awk sed

    while true; do
        check_network
        echo "Network check completed. Waiting 5 minutes before the next check..."
        sleep 300
    done
}

# Check if the script is being run as a command
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
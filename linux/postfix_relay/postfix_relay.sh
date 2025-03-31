#!/bin/bash

# Constants
POSTFIX_CONF="/etc/postfix/main.cf"
DEPENDENCIES=("postfix" "cyrus-sasl-plain" "mailx")
ACCESS_POSTFIX="/etc/postfix/sasl_passwd"

# Load environment variables or prompt user for input
RECIPIENT=${RECIPIENT:-$(read -p "Enter recipient email address: " tmp; echo $tmp)}
RELAY_SERVER=${RELAY_SERVER:-$(read -p "Enter relay server (SMTP server): " tmp; echo $tmp)}
RELAY_PORT=${RELAY_PORT:-$(read -p "Enter relay port (SMTP port): " tmp; echo $tmp)}
SMTP_USER=${SMTP_USER:-$(read -p "Enter SMTP user (email address): " tmp; echo $tmp)}
SMTP_PASSWORD=${SMTP_PASSWORD:-$(read -sp "Enter SMTP password: " tmp; echo $tmp; echo)}
MYHOSTNAME=${MYHOSTNAME:-$(read -p "Enter myhostname (e.g., www.mydomain.com): " tmp; echo $tmp)}
MYORIGIN=${MYORIGIN:-$(read -p "Enter myorigin (e.g., domain.com): " tmp; echo $tmp)}

# Parameters
SMTP_SERVER="[${RELAY_SERVER}]:${RELAY_PORT}"

# Functions

# Function to check and install necessary dependencies
# Iterates over the DEPENDENCIES array and installs any missing packages using yum
function check_and_install_dependencies() {
    for package in "${DEPENDENCIES[@]}"; do
        if ! rpm -q "$package" &>/dev/null; then
            echo "$package is not installed"
            yum install "$package" -y || { echo "The script cannot continue. Missing package: $package."; exit 1; }
        fi
    done
}

# Function to configure Postfix
# Appends necessary configuration settings to the Postfix main configuration file
function configure_postfix() {
    cat <<EOF >> "$POSTFIX_CONF"
myhostname = $MYHOSTNAME
myorigin = $MYORIGIN
relayhost = $SMTP_SERVER
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_password_maps = hash:$ACCESS_POSTFIX
smtp_tls_CAfile = /etc/ssl/certs/ca-bundle.crt
smtp_sasl_security_options = noanonymous
smtp_sasl_tls_security_options = noanonymous
EOF
}

# Function to configure access credentials for the relay server
# Creates the sasl_passwd file with the SMTP server credentials and sets appropriate permissions
function configure_access() {
    echo "$SMTP_SERVER $SMTP_USER:$SMTP_PASSWORD" > "$ACCESS_POSTFIX"
    postmap "$ACCESS_POSTFIX"
    chown root:postfix "$ACCESS_POSTFIX"*
    chmod 640 "$ACCESS_POSTFIX"*
}

# Function to restart and enable Postfix service
# Uses systemctl to restart and enable the Postfix service
function restart_postfix() {
    systemctl restart postfix
    systemctl enable postfix
}

# Function to send a test email
# Sends a test email to the specified recipient to confirm that the service is operating correctly
function send_test_email() {
    echo "This is a test message to confirm that the service is operating" | mail -s "Test Message" "$RECIPIENT"
}

# Main function
# Calls all the other functions in the correct order to set up and test the email relay
function main() {
    check_and_install_dependencies
    configure_postfix
    configure_access
    restart_postfix
    send_test_email
}

# Execute main function
main
#!/bin/bash
####################################################################
#
# Name: Keepalive Service
# Description: Script to keep a service running
# Version: 1.1
# Author: Juan Enrique Chomon Del Campo
# Date: 12-2020
# Repository:
#
################################ Usage ###############################
#
# ./keepalive.sh [service name]
#
# Example cron job executed every 5 minutes
# */5 * * * * /bin/sh /home/keepalive.sh [service name].service
# Logs in /var/log/cron
#
# Important
# Grant execution permission with chmod +x keepalive.sh
# Install mail package and configure relay
#
####################################################################

# Constants
MAIL="monitor@domain.com"
CLIENT="Client Name"
HOSTNAME=$(hostname | tr -d '-')

# Functions
function send_mail() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$MAIL"
}

function log_message() {
    local message="$1"
    echo "$(date +%d/%m/%Y-%H:%M:%S) $message"
}

function check_service_status() {
    local service="$1"
    systemctl -q is-active "$service"
}

function start_service() {
    local service="$1"
    systemctl start "$service"
}

function get_service_status() {
    local service="$1"
    systemctl status "$service"
}

# Main function
function main() {
    if [ $# -ne 1 ]; then
        echo "Usage: $0 [service name]"
        exit 1
    fi

    local service="$1"
    local service_name="${service//_}"
    local datetime_fmt="Service: $service - $CLIENT - $(date +%d/%m/%Y-%H:%M:%S)"

    if check_service_status "$service"; then
        log_message "$datetime_fmt $service is active"
    else
        log_message "$datetime_fmt $service is not active, attempting to restore."
        send_mail "${CLIENT}_${HOSTNAME}_${service_name}_Failed" "$datetime_fmt $service is not active, attempting to restore."

        start_service "$service"
        sleep 5

        if check_service_status "$service"; then
            log_message "$datetime_fmt $service has been restored automatically."
            send_mail "${CLIENT}_${HOSTNAME}_${service_name}_OK" "$datetime_fmt $service has been restored automatically."
            send_mail "Service Status" "$(get_service_status "$service")"
        else
            log_message "$datetime_fmt Failed to restore $service."
            send_mail "${CLIENT}_${HOSTNAME}_${service_name}_Failed" "$datetime_fmt Failed to restore $service."
        fi
    fi
}

# Execute main function
main "$@"
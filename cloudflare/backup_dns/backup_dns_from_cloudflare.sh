#!/bin/bash

# -----------------------------------------------------------------------------
# Script: backup_dns.sh
# Description: This script backs up DNS records from Cloudflare for all zones
#              associated with the provided API key. It saves the DNS records
#              to a file, compresses the file, and sends it via email.
#
# Usage:
#   ./backup_dns.sh
#
# Environment Variables:
#   DEFAULT_EMAIL       The default email address to send the backup to.
#   CLOUDFLARE_APIKEY   The Cloudflare API key for authentication.
#
# Example:
#   DEFAULT_EMAIL="user@example.com" CLOUDFLARE_APIKEY="your_api_key" ./backup_dns.sh
#
# Functions:
#   - fetch_zones: Fetches the list of zones from Cloudflare.
#   - backup_zone_dns: Backs up DNS records for a specific zone.
#   - send_backup_email: Sends the backup file via email.
#
# -----------------------------------------------------------------------------

EMAIL=${DEFAULT_EMAIL:-"<put_your_account_email>"}
APIKEY=${CLOUDFLARE_APIKEY:-"<put_your_cloudflare_api_key>"}
HOST="api.cloudflare.com"
DATE=$(date +%m-%Y)
FILENAME=cloudflare-dnszone-${DATE}.txt

# -----------------------------------------------------------------------------
# Function: fetch_zones
# Description: Fetches the list of zones from Cloudflare and saves it to a file.
# Arguments: None
# -----------------------------------------------------------------------------
fetch_zones() {
    sudo curl -X GET "https://${HOST}/client/v4/zones?per_page=50" \
        -H "Authorization: Bearer ${APIKEY}" \
        -H "Content-Type: application/json" \
        -o $FILENAME
}

# -----------------------------------------------------------------------------
# Function: backup_zone_dns
# Description: Backs up DNS records for a specific zone.
# Arguments:
#   $1 - The zone ID.
#   $2 - The zone name.
# -----------------------------------------------------------------------------
backup_zone_dns() {
    local zone_id=$1
    local zone_name=$2
    local url="https://${HOST}/client/v4/zones/${zone_id}/dns_records/export"
    curl -X GET $url \
        -H "Authorization: Bearer ${APIKEY}" \
        -H "Content-Type: application/json" \
        -o "$zone_name-$DATE.txt"
}

# -----------------------------------------------------------------------------
# Function: send_backup_email
# Description: Sends the backup file via email.
# Arguments: None
# -----------------------------------------------------------------------------
send_backup_email() {
    echo "Attached is the DNS backup" | mail -s "DNS Backup $DATE" -a backup-$DATE.tar.gz $EMAIL
}

# Main script execution
fetch_zones

ZONES=($(cat $FILENAME | jq -r '.result[] | "\(.id)|\(.name)"'))

DNS_FOLDER=dns/$DATE
mkdir -p $DNS_FOLDER
cd $DNS_FOLDER

for ZONE in ${ZONES[@]}; do
    ARR=($(echo $ZONE | tr "|" " "))
    ID=${ARR[0]}
    NAME=${ARR[1]}
    backup_zone_dns "$ID" "$NAME"
done

cd ..
sudo tar -cvzf ./backup-$DATE.tar.gz $DATE
sudo rm -rf $DATE/

send_backup_email

sleep 5
sudo rm -rf backup-$DATE.tar.gz $FILENAME $DNS_FOLDER
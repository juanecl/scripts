#!/bin/bash
####################################################################
#
# Name: MySQL/MariaDB Monitoring Script
# Description: This script monitors the performance and health of a MySQL/MariaDB database.
# Version: 1.2
# Author: Juan Enrique Chomon Del Campo
# Date: 02-2025
#
################################ Usage ###############################
#
# ./monitor.sh -u <db_user> -p <db_password> -h <db_host> -P <db_port> <db_name>
#
# Example cron job executed every 5 minutes
# */5 * * * * /bin/bash /path/to/monitor.sh -u <db_user> -p <db_password> -h <db_host> -P <db_port> <db_name>
#
# Important
# Give execution permission with chmod +x monitor.sh
#
####################################################################

# Function to execute a MySQL/MariaDB command
execute_mysql_command() {
    local COMMAND=$1
    local DB_USER=$2
    local DB_PASSWORD=$3
    local DB_HOST=$4
    local DB_PORT=$5
    local DB_NAME=$6

    mysql --protocol=tcp -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" -e "$COMMAND" "$DB_NAME"
}

# Function to execute a MySQL/MariaDB admin command
execute_mysqladmin_command() {
    local COMMAND=$1
    local DB_USER=$2
    local DB_PASSWORD=$3
    local DB_HOST=$4
    local DB_PORT=$5

    mysqladmin --protocol=tcp -u "$DB_USER" -p"$DB_PASSWORD" -h "$DB_HOST" -P "$DB_PORT" "$COMMAND"
}

# Function to check MySQL/MariaDB server status
check_mysql_status() {
    execute_mysqladmin_command "ping" "$1" "$2" "$3" "$4"
}

# Function to get MySQL/MariaDB server statistics
get_mysql_stats() {
    execute_mysqladmin_command "status" "$1" "$2" "$3" "$4"
}

# Function to get MySQL/MariaDB database size
get_mysql_db_size() {
    local DB_USER=$1
    local DB_PASSWORD=$2
    local DB_HOST=$3
    local DB_PORT=$4
    local DB_NAME=$5

    local COMMAND="SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.TABLES WHERE table_schema = '$DB_NAME' GROUP BY table_schema;"
    execute_mysql_command "$COMMAND" "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_PORT" "$DB_NAME"
}

# Main script execution
while getopts u:p:h:P: flag
do
    case "${flag}" in
        u) DB_USER=${OPTARG};;
        p) DB_PASSWORD=${OPTARG};;
        h) DB_HOST=${OPTARG};;
        P) DB_PORT=${OPTARG};;
        *) echo "Usage: $0 -u <db_user> -p <db_password> -h <db_host> -P <db_port> <db_name>"; exit 1;;
    esac
done
shift $((OPTIND -1))

DB_NAME=$1

if [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_NAME" ]; then
    echo "Usage: $0 -u <db_user> -p <db_password> -h <db_host> -P <db_port> <db_name>"
    exit 1
fi

echo "Checking MySQL/MariaDB server status..."
check_mysql_status "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_PORT"

echo "Getting MySQL/MariaDB server statistics..."
get_mysql_stats "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_PORT"

echo "Getting MySQL/MariaDB database size..."
get_mysql_db_size "$DB_USER" "$DB_PASSWORD" "$DB_HOST" "$DB_PORT" "$DB_NAME"
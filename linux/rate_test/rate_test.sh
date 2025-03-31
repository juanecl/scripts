#!/bin/bash

# -----------------------------------------------------------------------------
# Script: rate_test.sh
# Description: This script performs a rate test by sending a specified number
#              of HTTP requests to a given URL. It validates the URL and the
#              number of requests, then sends the requests in parallel while
#              displaying a loader animation. The results are displayed with
#              HTTP status codes and their counts.
#
# Usage:
#   ./rate_test.sh <url> <requests>
#
# Arguments:
#   <url>       The URL to which the HTTP requests will be sent.
#   <requests>  The number of HTTP requests to send (between 1 and 5000).
#
# Example:
#   ./rate_test.sh https://example.com 100
#
# Functions:
#   - validate_url: Validates the provided URL.
#   - validate_requests: Validates the number of requests.
#   - loader: Displays a loader animation while requests are being sent.
#   - rate_test: Performs the rate test by sending HTTP requests.
#
# -----------------------------------------------------------------------------

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Function: validate_url
# Description: Validates the provided URL to ensure it is in the correct format.
# Arguments:
#   $1 - The URL to validate.
# Returns:
#   0 if the URL is valid, 1 otherwise.
# -----------------------------------------------------------------------------
validate_url() {
    local url=$1
    if echo "$url" | grep -E '^https?://[^ ]+$' > /dev/null; then
        return 0
    else
        echo "The provided URL ($url) is not valid."
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function: validate_requests
# Description: Validates the number of requests to ensure it is a number
#              between 1 and 5000.
# Arguments:
#   $1 - The number of requests to validate.
# Returns:
#   0 if the number of requests is valid, 1 otherwise.
# -----------------------------------------------------------------------------
validate_requests() {
    local count=$1
    if ! echo "$count" | grep -E '^[0-9]+$' > /dev/null || [ "$count" -lt 1 ] || [ "$count" -gt 5000 ]; then
        echo "The number of requests ($count) is invalid. It must be a number between 1 and 5000."
        return 1
    fi
    return 0
}

# -----------------------------------------------------------------------------
# Function: loader
# Description: Displays a loader animation while the requests are being sent.
# Arguments:
#   $1 - The PID of the background process to wait for.
# -----------------------------------------------------------------------------
loader() {
    local pid=$1
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps -p "$pid" -o pid=)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# -----------------------------------------------------------------------------
# Function: rate_test
# Description: Performs the rate test by sending the specified number of HTTP
#              requests to the given URL in parallel.
# Arguments:
#   $1 - The URL to send requests to.
#   $2 - The number of requests to send.
# -----------------------------------------------------------------------------
rate_test() {
    local url=$1
    local requests=$2

    # Calculate the period for parallel requests
    local period=$(echo "scale=2; ($requests/60)+0.5" | bc | awk '{print int($1+0.5)}')

    echo -e "${GREEN}Sending $requests requests to $url (${period} requests/second). Please wait...${NC}"

    # Run requests in the background and capture PID
    (
        time (
            seq "$requests" | xargs -n1 -P"$period" -I{} curl -s -o /dev/null -w "%{http_code}\n" "$url" | \
            sort | uniq -c | awk -v red="$RED" -v nc="$NC" '{if ($2 >= 500 && $2 < 600) print red "\tHTTP "$2"\t"$1 nc; else print "\tHTTP "$2"\t"$1}' | column -t
        )
    ) &
    local pid=$!

    # Show loader while requests are running
    loader "$pid"
}

# CLI logic
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ensure arguments are provided
    if [ "$#" -ne 2 ]; then
        echo -e "${RED}Usage: $0 <url> <requests>${NC}"
        echo "Example: $0 https://example.com 100"
        exit 1
    fi

    url=$1
    requests=$2

    # Validate inputs
    validate_url "$url" || exit 1
    validate_requests "$requests" || exit 1

    # Run the rate test
    rate_test "$url" "$requests"
fi
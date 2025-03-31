#!/bin/bash

# Usage: svn_merge {trunk url} {branch url}
# This script requires 2 parameters. The first one is the full URL of the trunk and the second is the full URL of the branch. Do not add trailing slashes in the URLs.

# Constants
TMP_DIR=~/svn/temp_merge_dir/
SVN_USER=$(whoami) # Change to your SVN username
SVN_PASS="Add your SVN password"

# Functions
function authenticate_svn() {
    svn auth --username $SVN_USER --password $SVN_PASS
    echo "$SVN_USER authenticated successfully"
}

function create_temp_dir() {
    mkdir -p $TMP_DIR
    echo "$TMP_DIR temporary folder created"
}

function check_svn_url() {
    local url=$1
    svn info $url 2>/dev/null
}

function checkout_svn_repo() {
    local url=$1
    svn checkout $url
}

function main() {
    if [ $# -ne 2 ]; then
        echo "Usage: $0 {trunk url} {branch url}"
        exit 1
    fi

    local TRUNK=$1
    local BRANCH=$2
    local BRANCH_DIR=$(basename $BRANCH)
    local MERGED_DIR="MERGED_$BRANCH_DIR"
    local TRUNK_DIR=$(basename $TRUNK)
    local NEW_BRANCH=${BRANCH/$BRANCH_DIR/$MERGED_DIR}

    authenticate_svn

    local CURRENT_DIR=$(pwd)
    local BASE_DIR=$CURRENT_DIR

    create_temp_dir
    cd $TMP_DIR

    if [ -z "$(check_svn_url $TRUNK)" ]; then
        echo "The trunk $TRUNK doesn't exist"
        exit 1
    fi

    checkout_svn_repo $TRUNK
    cd $TRUNK_DIR
    CURRENT_DIR=$(pwd)

    if [ "$CURRENT_DIR" == "$BASE_DIR/$TRUNK_DIR" ]; then
        echo "Trunk downloaded and accessed successfully"

        if [ -z "$(check_svn_url $BRANCH)" ]; then
            echo "The branch $BRANCH doesn't exist"
            exit 1
        fi

        # Additional merge logic can be added here
    fi
}

# Execute main function
main "$@"
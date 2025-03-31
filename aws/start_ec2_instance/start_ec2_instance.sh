#!/bin/bash

# -----------------------------------------------------------------------------
# Script: start_instance.sh
# Description: This script starts an AWS EC2 instance and verifies its status.
#              It checks if the AWS CLI is installed and configured, verifies
#              the existence of the EC2 instance, and waits for the instance
#              to start. If the instance does not start within 10 minutes, it
#              sends an email notification.
#
# Usage:
#   ./start_instance.sh <instance-id> <region> <tag>
#
# Arguments:
#   <instance-id>  The ID of the EC2 instance to start.
#   <region>       The AWS region where the EC2 instance is located.
#   <tag>          A tag to identify the instance in logs and notifications.
#
# Example:
#   ./start_instance.sh i-1234567890abcdef us-east-1 MyInstance
#
# -----------------------------------------------------------------------------

REGION=$2
INSTANCE_ID=$1
TAG=$3

# -----------------------------------------------------------------------------
# Function: check_aws_cli_installed
# Description: Checks if the AWS CLI is installed.
# -----------------------------------------------------------------------------
check_aws_cli_installed() {
    if ! command -v aws &> /dev/null; then
        echo "$(date) ERROR: AWS CLI is not installed"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Function: check_aws_cli_configured
# Description: Checks if the AWS CLI is configured.
# -----------------------------------------------------------------------------
check_aws_cli_configured() {
    if [ -z "$(aws configure get aws_access_key_id)" ] || [ -z "$(aws configure get aws_secret_access_key)" ]; then
        echo "$(date) ERROR: AWS CLI is not configured"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Function: check_arguments_provided
# Description: Checks if the necessary arguments are provided.
# -----------------------------------------------------------------------------
check_arguments_provided() {
    if [ -z "$INSTANCE_ID" ] || [ -z "$REGION" ]; then
        echo "$(date) ERROR: You must provide the instance-id and region as arguments"
        exit 1
    fi
}

# -----------------------------------------------------------------------------
# Function: check_instance_exists
# Description: Checks if the EC2 instance exists.
# Arguments:
#   $1 - The ID of the EC2 instance.
#   $2 - The AWS region where the EC2 instance is located.
# -----------------------------------------------------------------------------
check_instance_exists() {
    local instance_id=$1
    local region=$2
    local instance_exists=$(aws ec2 describe-instances --instance-ids $instance_id --region $region 2>/dev/null)
    if [ -z "$instance_exists" ]; then
        echo "$(date) ERROR: No EC2 instance found with the provided ID"
        exit 1
    fi
}

# Main script execution
check_aws_cli_installed
check_aws_cli_configured
check_arguments_provided
check_instance_exists $INSTANCE_ID $REGION

MESSAGE="$(date) INFO: Starting AWS EC2 instance $TAG ($INSTANCE_ID)"
echo $MESSAGE

/usr/bin/aws ec2 start-instances --instance-ids $INSTANCE_ID --region $REGION > /dev/null 2>&1

# Wait up to 10 minutes for the instance to start
for i in {1..60}; do
    INSTANCE_STATE=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --region $REGION --query 'Reservations[*].Instances[*].State.Name' --output text)
    if [ "$INSTANCE_STATE" == "running" ]; then
        echo "$(date) INFO: EC2 instance $INSTANCE_ID ($TAG) has started successfully"
        echo $MESSAGE | mail -s "$(date) INFO: EC2 instance $INSTANCE_ID ($TAG) started" <put_your_email_here>
        exit 0
    fi
    sleep 10
done

# If the instance has not started after 10 minutes, send an email notification
echo "$(date) INFO: EC2 instance $INSTANCE_ID ($TAG) did not start after 10 minutes" | mail -s "Error starting EC2 instance $INSTANCE_ID ($TAG)" <put_your_email_here>
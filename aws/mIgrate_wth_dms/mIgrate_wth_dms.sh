#!/bin/bash

# -----------------------------------------------------------------------------
# Script: migrate.sh
# Description: This script automates the process of migrating data using AWS
#              Database Migration Service (DMS). It creates a replication
#              instance, sets up replication tasks, tests connectivity, runs
#              the migration, and cleans up resources.
#
# Usage:
#   ./migrate.sh
#
# Environment Variables:
#   DEFAULT_EMAIL       The default email address to send notifications to.
#
# Example:
#   DEFAULT_EMAIL="user@example.com" ./migrate.sh
#
# Functions:
#   - run: Main function to orchestrate the migration process.
#   - create_replication_instance: Creates a replication instance.
#   - create_replication_task: Creates a replication task.
#   - test_connection: Tests connectivity to the source and target endpoints.
#   - run_replication_task: Runs the replication task.
#   - delete_replication_task: Deletes the replication task.
#   - delete_replication_instance: Deletes the replication instance.
#   - unattended_emergency_task_deletion: Deletes a replication task in case of an emergency.
#   - unattended_emergency_instance_deletion: Deletes a replication instance in case of an emergency.
#   - unattended_emergency_deletion: Deletes both replication task and instance in case of an emergency.
#
# -----------------------------------------------------------------------------

run() {
    # TODO: Parameterize REGION
    CURRENT_DATE=$(date +%Y%m%d-%H%M%S)
    EMAIL=${DEFAULT_EMAIL:-"<put_your_account_email>"}

    # Replication task
    TASK_ID="dwh-replication-$CURRENT_DATE" # Arbitrary replication task name

    # Replication instance
    INSTANCE_ID="dwh-instance-$CURRENT_DATE" # Arbitrary replication instance name

    # Endpoints
    # TODO: Parameterize
    SOURCE=<source_endpoint_arn>
    TARGET=<target_endpoint_arn>

    echo "$(date +%H:%M:%S) Starting migration process with $TASK_ID at $INSTANCE_ID"

    ##############################################################################################
    # Step 1: Create the replication instance
    ##############################################################################################
    echo "$(date +%H:%M:%S) Replication instance creation $INSTANCE_ID started"
    REPLICATION_INSTANCE_ARN=$(create_replication_instance $INSTANCE_ID $EMAIL)
    if [ -z "$REPLICATION_INSTANCE_ARN" ]; then
        echo "ERROR: REPLICATION_INSTANCE_ARN is empty"
        exit 1
    else
        echo "INFO: Replication instance ARN: $REPLICATION_INSTANCE_ARN"
    fi
    echo "$(date +%H:%M:%S) Replication instance creation $INSTANCE_ID finished successfully"

    ##############################################################################################
    # Step 2: Create the replication task
    ##############################################################################################
    echo "$(date +%H:%M:%S) Replication task creation $INSTANCE_ID started"
    REPLICATION_TASK_ARN=$(create_replication_task $TASK_ID $SOURCE $TARGET $REPLICATION_INSTANCE_ARN $EMAIL)
    if [ -z "$REPLICATION_TASK_ARN" ]; then
        echo "ERROR: REPLICATION_TASK_ARN is empty"
        unattended_emergency_task_deletion $REPLICATION_TASK_ARN
        exit 1
    else
        echo "INFO: Replication task ARN: $REPLICATION_TASK_ARN"
    fi
    echo "$(date +%H:%M:%S) Replication task creation $INSTANCE_ID finished successfully"

    ##############################################################################################
    # Step 3: Test connectivity to the source endpoint
    ##############################################################################################
    # Validate the connection to the source endpoint.
    test_connection $REPLICATION_INSTANCE_ARN $REPLICATION_TASK_ARN $SOURCE $EMAIL
    echo "$(date +%H:%M:%S) Connectivity to source endpoint ended successfully"

    ##############################################################################################
    # Step 4: Test connectivity to the target endpoint
    ##############################################################################################
    # Validate the connection to the target endpoint.
    test_connection $REPLICATION_INSTANCE_ARN $REPLICATION_TASK_ARN $TARGET $EMAIL
    echo "$(date +%H:%M:%S) Connectivity to target endpoint ended successfully"

    ##############################################################################################
    # Step 5: Run the data migration between the endpoints.
    ##############################################################################################
    run_replication_task $REPLICATION_TASK_ARN $EMAIL
    echo "$(date +%H:%M:%S) Replication task executed successfully"

    ##############################################################################################
    # Step 6: Delete the replication task.
    # IMPORTANT: The replication instance cannot be deleted
    # if the replication task has not been deleted.
    ##############################################################################################
    delete_replication_task $REPLICATION_TASK_ARN $EMAIL
    echo "$(date +%H:%M:%S) Replication task deletion completed successfully"

    ##############################################################################################
    # Step 7: Delete the replication instance.
    ##############################################################################################
    delete_replication_instance $REPLICATION_INSTANCE_ARN $EMAIL
    echo "$(date +%H:%M:%S) Replication instance deletion completed successfully"
    echo "$(date +%H:%M:%S) Replication task $TASK_ID at $INSTANCE_ID finished successfully"
}

# -----------------------------------------------------------------------------
# Function: create_replication_instance
# Description: Creates a replication instance.
# Arguments:
#   $1 - The replication instance ID.
#   $2 - The email address for notifications.
# Returns:
#   The ARN of the created replication instance.
# -----------------------------------------------------------------------------
create_replication_instance() {
    REGION=<aws_region>
    INSTANCE_ID=$1
    INSTANCE_ARN=""
    INSTANCE_CLASS=<instance_class>
    INSTANCE_STORAGE=<instance_storage>
    INSTANCE_SUBNET_GROUP=<subnet_group>
    INSTANCE_SECURITY_GROUP=<security_group>
    EMAIL=$2

    aws dms create-replication-instance \
        --replication-instance-identifier $INSTANCE_ID \
        --replication-instance-class $INSTANCE_CLASS \
        --allocated-storage $INSTANCE_STORAGE \
        --vpc-security-group-ids $INSTANCE_SECURITY_GROUP \
        --no-multi-az \
        --replication-subnet-group-identifier $INSTANCE_SUBNET_GROUP \
        --region $REGION > /dev/null 2>&1

    # Wait until the replication instance is available
    START_TIME=$(date +%s)
    while true; do
        INSTANCE_STATUS=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=$INSTANCE_ID --query 'ReplicationInstances[0].ReplicationInstanceStatus' --output text --region $REGION)
        if [ "$INSTANCE_STATUS" == "available" ]; then
            INSTANCE_ARN=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=$INSTANCE_ID --query 'ReplicationInstances[0].ReplicationInstanceArn' --output text --region $REGION)
            break
        else
            sleep 60
        fi

        # Check if 20 minutes have passed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 1200 ]; then
            echo "ERROR: Replication instance did not become available after 20 minutes" | mail -s "DMS Task Alert" $EMAIL > /dev/null 2>&1
            exit 1
        fi
    done
    echo $INSTANCE_ARN
}

# -----------------------------------------------------------------------------
# Function: create_replication_task
# Description: Creates a replication task.
# Arguments:
#   $1 - The replication task ID.
#   $2 - The source endpoint ARN.
#   $3 - The target endpoint ARN.
#   $4 - The replication instance ARN.
#   $5 - The email address for notifications.
# Returns:
#   The ARN of the created replication task.
# -----------------------------------------------------------------------------
create_replication_task() {
    TASK_ARN=""
    TASK_ID=$1
    SOURCE=$2
    TARGET=$3
    INSTANCE_ARN=$4
    EMAIL=$5

    REGION=us-east-1
    aws dms create-replication-task \
        --replication-task-identifier $TASK_ID \
        --source-endpoint-arn $SOURCE \
        --target-endpoint-arn $TARGET \
        --migration-type full-load \
        --table-mappings '{
            "rules": [
                {
                    "rule-type": "selection",
                    "rule-id": "1",
                    "rule-name": "1",
                    "object-locator": {
                        "schema-name": "public",
                        "table-name": "%"
                    },
                    "rule-action": "include"
                }
            ]
        }' \
        --replication-task-settings '{
            "TargetMetadata": {
                "BatchApplyEnabled": true
            }
        }' \
        --replication-instance-arn $INSTANCE_ARN \
        --region $REGION --output json > /dev/null 2>&1

    # Wait until the replication task is ready
    START_TIME=$(date +%s)
    while true; do
        TASK_STATUS=$(aws dms describe-replication-tasks --filters Name=replication-task-id,Values=$TASK_ID --query 'ReplicationTasks[0].Status' --output text --region $REGION)
        if [ "$TASK_STATUS" == "ready" ]; then
            TASK_ARN=$(aws dms describe-replication-tasks --filters Name=replication-task-id,Values=$TASK_ID --query 'ReplicationTasks[0].ReplicationTaskArn' --output text --region $REGION)
            break
        else
            sleep 60
        fi

        # Check if 20 minutes have passed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 1200 ]; then
            echo "ERROR: Replication task did not become ready after 20 minutes" | mail -s "DMS Task Alert" $EMAIL > /dev/null 2>&1
            exit 1
        fi
    done
    echo $TASK_ARN
}

# -----------------------------------------------------------------------------
# Function: test_connection
# Description: Tests the connection to the specified endpoint.
# Arguments:
#   $1 - The replication instance ARN.
#   $2 - The replication task ARN.
#   $3 - The endpoint ARN.
#   $4 - The email address for notifications.
# -----------------------------------------------------------------------------
test_connection() {
    REGION=<aws_region>
    INSTANCE_ARN=$1
    TASK_ARN=$2
    ENDPOINT_ARN=$3
    EMAIL=$4

    echo "INFO: Testing connection to $ENDPOINT_ARN endpoint..."
    aws dms test-connection --replication-instance-arn $INSTANCE_ARN --endpoint-arn $ENDPOINT_ARN --region $REGION

    # Wait until the connection test is successful
    START_TIME=$(date +%s)
    while true; do
        CONNECTION_STATUS=$(aws dms describe-connections --filters Name=endpoint-arn,Values=$ENDPOINT_ARN --query 'Connections[0].Status' --output text --region $REGION)
        if [ "$CONNECTION_STATUS" == "successful" ]; then
            break
        else
            echo "INFO: Waiting for connection test to $ENDPOINT_ARN endpoint to be successful..."
            sleep 60
        fi

        # Check if 20 minutes have passed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 1200 ]; then
            echo "ERROR: Connection test to $ENDPOINT_ARN endpoint did not become successful after 20 minutes" | mail -s "DMS Task Alert" $EMAIL
            unattended_emergency_deletion $INSTANCE_ARN $TASK_ARN
            exit 1
        fi
    done
}

# -----------------------------------------------------------------------------
# Function: run_replication_task
# Description: Starts the replication task.
# Arguments:
#   $1 - The replication task ARN.
#   $2 - The email address for notifications.
# -----------------------------------------------------------------------------
run_replication_task() {
    REGION=<aws_region>
    TASK_ARN=$1
    EMAIL=$2
    TASK_TYPE=reload-target

    aws dms start-replication-task --replication-task-arn $TASK_ARN --start-replication-task-type $TASK_TYPE --region $REGION

    # Record the start time of the task
    TASK_START_TIME=$(date +%s)

    # Wait until the replication task has finished
    START_TIME=$(date +%s)
    while true; do
        TASK_STATUS=$(aws dms describe-replication-tasks --filters Name=replication-task-arn,Values=$TASK_ARN --query 'ReplicationTasks[0].Status' --output text --region $REGION)
        if [ "$TASK_STATUS" == "stopped" ]; then
            break
        else
            echo "INFO: Waiting for replication task to finish..."
            sleep 300
        fi
    done

    # Record the end time of the task
    TASK_END_TIME=$(date +%s)

    # Calculate the duration of the task
    TASK_DURATION=$((TASK_END_TIME - TASK_START_TIME))
    MINUTES=$((TASK_DURATION / 60))
    SECONDS=$((TASK_DURATION % 60))

    # Send an email with the duration of the task
    echo "INFO: Replication task finished in $MINUTES minutes and $SECONDS seconds" | mail -s "DMS Task Completed" $EMAIL
}

# -----------------------------------------------------------------------------
# Function: delete_replication_task
# Description: Deletes the replication task.
# Arguments:
#   $1 - The replication task ARN.
#   $2 - The email address for notifications.
# -----------------------------------------------------------------------------
delete_replication_task() {
    REGION=<aws_region>
    TASK_ARN=$1
    EMAIL=$2
    
    unattended_emergency_task_deletion $TASK_ARN $REGION > /dev/null 2>&1

    # Wait until the replication task has been deleted
    START_TIME=$(date +%s)
    while true; do
        TASK_STATUS=$(aws dms describe-replication-tasks --filters Name=replication-task-arn,Values=$TASK_ARN --query 'ReplicationTasks[0].Status' --output text --region $REGION 2>/dev/null)
        if [ -z "$TASK_STATUS" ]; then
            break
        else
            echo "INFO: Waiting for replication task to be deleted..."
            sleep 60
        fi

        # Check if 20 minutes have passed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 1200 ]; then
            ERROR_MESSAGE="Replication task $TASK_ARN: After 20 minutes waiting we were unable to confirm deletion. Please go to DMS website and delete manually. Error occurred at $(date)"
            echo $ERROR_MESSAGE | mail -s "DMS Task Alert" $EMAIL
            exit 1
        fi
    done
}

# -----------------------------------------------------------------------------
# Function: delete_replication_instance
# Description: Deletes the replication instance.
# Arguments:
#   $1 - The replication instance ARN.
#   $2 - The email address for notifications.
# -----------------------------------------------------------------------------
delete_replication_instance() {
    REGION=<aws_region>
    INSTANCE_ARN=$1
    EMAIL=$2
    
    unattended_emergency_instance_deletion $INSTANCE_ARN $REGION > /dev/null 2>&1

    # Wait until the replication instance has been deleted
    START_TIME=$(date +%s)
    while true; do
        INSTANCE_STATUS=$(aws dms describe-replication-instances --filters Name=replication-instance-id,Values=$INSTANCE_ID --query 'ReplicationInstances[0].ReplicationInstanceStatus' --output text --region $REGION 2>/dev/null)
        if [ -z "$INSTANCE_STATUS" ]; then
            break
        else
            echo "INFO: Waiting for replication instance to be deleted..."
            sleep 60
        fi

        # Check if 20 minutes have passed
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        if [ $ELAPSED_TIME -ge 1200 ]; then
            ERROR_MESSAGE="Replication instance $INSTANCE_ID: After 20 minutes waiting we were unable to confirm deletion. Please go to DMS website and delete manually. Error occurred at $(date)"
            echo $ERROR_MESSAGE | mail -s "DMS Task Alert: $INSTANCE_ID" $EMAIL
            exit 1
        fi
    done
}

# -----------------------------------------------------------------------------
# Function: unattended_emergency_task_deletion
# Description: Deletes a replication task in case of an emergency.
# Arguments:
#   $1 - The replication task ARN.
#   $2 - The AWS region.
# -----------------------------------------------------------------------------
unattended_emergency_task_deletion() {
    aws dms delete-replication-task --replication-task-arn $1 --region $2
}

# -----------------------------------------------------------------------------
# Function: unattended_emergency_instance_deletion
# Description: Deletes a replication instance in case of an emergency.
# Arguments:
#   $1 - The replication instance ARN.
#   $2 - The AWS region.
# -----------------------------------------------------------------------------
unattended_emergency_instance_deletion() {
    aws dms delete-replication-instance --replication-instance-arn $1 --region $2
}

# -----------------------------------------------------------------------------
# Function: unattended_emergency_deletion
# Description: Deletes both replication task and instance in case of an emergency.
# Arguments:
#   $1 - The replication instance ARN.
#   $2 - The replication task ARN.
# -----------------------------------------------------------------------------
unattended_emergency_deletion() {
    REGION=<aws_region>
    INSTANCE_ARN=$1
    TASK_ARN=$2
    
    unattended_emergency_task_deletion $TASK_ARN $REGION
    sleep 600
    unattended_emergency_instance_deletion $INSTANCE_ARN $REGION
}

run
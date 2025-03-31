# AWS DMS Migration Script (`migrate.sh`)

## Description
This script automates the process of migrating data using AWS Database Migration Service (DMS). It performs the following actions:

1. Creates a replication instance.
2. Sets up replication tasks.
3. Tests connectivity between source and target endpoints.
4. Runs the migration process.
5. Cleans up resources by deleting the replication task and instance.
6. Handles emergency deletions if necessary.

## Usage
```bash
./migrate.sh
```

## Environment Variables
The script can use environment variables for configuration:

- `DEFAULT_EMAIL`: Email address to send notifications for status updates and alerts.
  
Example:
```bash
DEFAULT_EMAIL="user@example.com" ./migrate.sh
```

## AWS Prerequisites
Ensure the following before running the script:

- **AWS CLI Installed:**
  ```bash
  aws --version
  ```
  If not installed, follow the guide: [AWS CLI Installation](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

- **AWS CLI Configured:**
  ```bash
  aws configure
  ```
  The script checks if AWS credentials are properly set up.

- **IAM Permissions:**
  The script requires the following AWS permissions:
  - `dms:CreateReplicationInstance`
  - `dms:CreateReplicationTask`
  - `dms:StartReplicationTask`
  - `dms:DeleteReplicationTask`
  - `dms:DeleteReplicationInstance`
  - `dms:TestConnection`
  - `dms:DescribeReplicationInstances`
  - `dms:DescribeReplicationTasks`

## Execution Steps
### 1. Start the Migration
The script generates unique IDs for the replication task and instance based on the current timestamp.

### 2. Create a Replication Instance
A new AWS DMS replication instance is created with the specified instance class, storage, and networking configurations.

### 3. Create a Replication Task
The task is created using:
- A full-load migration type.
- Custom table-mapping rules.
- Target metadata settings to enable batch apply.

### 4. Test Source and Target Connections
The script verifies connectivity to both source and target endpoints.

### 5. Run the Migration Task
The replication task starts, and the script monitors its status until completion.

### 6. Cleanup
Once migration is complete, the script:
- Deletes the replication task.
- Deletes the replication instance.

## Emergency Handling
If any process fails:
- The script attempts to delete the replication task and instance.
- If deletion fails after 20 minutes, an email notification is sent.

## Logs & Notifications
- The script logs progress messages in the console.
- Email alerts are sent if failures occur or after successful migration.

## Customization
Modify the following parameters in the script if needed:
- **AWS Region:** Replace `<aws_region>` with your preferred AWS region.
- **Instance Class & Storage:** Adjust `<instance_class>` and `<instance_storage>` as needed.
- **Subnets & Security Groups:** Ensure correct values for `<subnet_group>` and `<security_group>`.

## Example Execution
```bash
DEFAULT_EMAIL="admin@example.com" ./migrate.sh
```

## Troubleshooting
- **Issue: Replication instance creation takes too long**
  - Check your AWS service quotas for DMS replication instances.
  - Verify instance class and region availability.

- **Issue: Connection test to source or target fails**
  - Ensure proper security group rules allow connections.
  - Verify database endpoint credentials in AWS DMS.

- **Issue: Migration is slow**
  - Modify replication task settings to optimize performance.

- **Issue: Script exits with an error**
  - Check the error message and manually verify AWS DMS resources.
  - Run `aws dms describe-replication-tasks` and `aws dms describe-replication-instances` for debugging.

## Additional References
- [AWS DMS Documentation](https://docs.aws.amazon.com/dms/latest/userguide/Welcome.html)
- [AWS CLI Reference for DMS](https://docs.aws.amazon.com/cli/latest/reference/dms/)

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
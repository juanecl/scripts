# GCP Secret Manager CLI

## Overview
This project provides a CLI tool to manage Google Cloud Platform (GCP) secrets using GCP Secret Manager. It allows users to create, retrieve, list, and delete secrets efficiently.

## Installation
Ensure you have Python 3 installed on your system and authenticate your GCP account:

```sh
pip install google-cloud-secret-manager
```

Authenticate with GCP:

```sh
gcloud auth application-default login
```

## Usage
Run the CLI script using the following commands:

### Create or Update a Secret
```sh
./manager-cli.py create --name my_secret --value MySecurePassword123! --project-id your-gcp-project-id
```

### Retrieve a Secret
```sh
./manager-cli.py get --name my_secret --project-id your-gcp-project-id
```

### List Secrets
```sh
./manager-cli.py list --project-id your-gcp-project-id
```

### Delete a Secret
```sh
./manager-cli.py delete --name my_secret --project-id your-gcp-project-id
```

## Arguments
- `action`: The action to perform (`create`, `get`, `list`, `delete`).
- `--name`: The name of the secret.
- `--value`: The value of the secret (required for `create` action).
- `--project-id`: The GCP Project ID.

## Implementation
This project consists of two primary files:

1. `manager-cli.py`: CLI tool for managing GCP secrets.
2. `manager.py`: Contains the `GCPSecretManager` class for handling secret operations.

### GCPSecretManager Class
This class provides the following methods:

- `create_or_update_secret(secret_name, secret_value)`: Creates or updates a secret.
- `get_secret(secret_name)`: Retrieves the latest version of a secret.
- `list_secrets()`: Lists all secrets in the project.
- `delete_secret(secret_name)`: Deletes a specified secret.

### Error Handling
The class handles exceptions such as `NotFound` and `AlreadyExists` to ensure smooth execution.

## Example Usage
```python
from manager import GCPSecretManager

secret_manager = GCPSecretManager(project_id="your-gcp-project-id")

# Create or update a secret
secret_manager.create_or_update_secret("my_secret", "MySecurePassword123!")

# Retrieve a secret
print(secret_manager.get_secret("my_secret"))

# List secrets
print(secret_manager.list_secrets())

# Delete a secret
secret_manager.delete_secret("my_secret")
```

## License
This project is licensed under the MIT License.

## Author
Juan Enrique Chomon Del Campo
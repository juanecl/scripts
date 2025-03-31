# AWS Secrets Manager Client

## Overview
This Python script provides a reusable client class (`SecretsManagerClient`) to interact with AWS Secrets Manager. It allows users to create, update, retrieve, delete, and restore secrets stored in AWS.

## Features
- ✅ Create or update a secret
- 🔍 Retrieve a secret
- 📋 List all stored secrets
- 🗑️ Delete a secret (with optional permanent deletion)
- ♻️ Restore a deleted secret
- ⚠️ Handles errors and exceptions gracefully

## Prerequisites
- Python 3.x installed
- `boto3` installed:
  ```bash
  pip install boto3
  ```
- AWS credentials configured using `aws configure` or environment variables
- IAM permissions to manage secrets in AWS Secrets Manager

## Usage

### Import and Initialize the Client
```python
from secrets_manager import SecretsManagerClient

secrets_client = SecretsManagerClient(region="us-east-1")
```

### Create or Update a Secret
```python
secrets_client.create_or_update_secret("my_secret", "MySecurePassword123!")
```

### Retrieve a Secret
```python
secret_value = secrets_client.get_secret("my_secret")
print(f"🔑 Secret value: {secret_value}")
```

### List All Secrets
```python
secrets = secrets_client.list_secrets()
print(f"📋 List of secrets: {secrets}")
```

### Delete a Secret
```python
secrets_client.delete_secret("my_secret")  # Moves secret to deletion with recovery
```

### Permanently Delete a Secret
```python
secrets_client.delete_secret("my_secret", force_delete=True)  # No recovery
```

### Restore a Deleted Secret
```python
secrets_client.restore_secret("my_secret")
```

## Error Handling
The client includes error handling for various AWS errors, including:
- Secret not found
- Access denied
- AWS service issues

Errors are printed with descriptive messages to help debug issues.

## License
This project is designed for sharing as a **Gist**, not a full repository.

## Author
Juan Enrique Chomon Del Campo

## Contributions
Feel free to submit improvements or suggestions!


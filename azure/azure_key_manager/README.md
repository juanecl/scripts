# Azure Key Vault Manager

## Description

**Azure Key Vault Manager** is a Python tool that allows secure management of secrets stored in **Azure Key Vault**. It provides functions to create, retrieve, list, delete, and restore secrets using the **Azure SDK for Python**. Additionally, it includes a **CLI interface** for easy usage without modifying the code.

## Features

- ✅ Create and update secrets in **Azure Key Vault**.
- 🔑 Retrieve secret values.
- 📋 List stored secrets.
- 🗑️ Delete and restore deleted secrets.
- 🖥️ Easy command-line interface (**CLI**) usage.

## Installation

To use this manager, ensure you have **Python 3.7+** installed and run:

```sh
pip install azure-identity azure-keyvault-secrets
```

## Configuration

You must log in to **Azure CLI** to authenticate with **Azure Key Vault**:

```sh
az login
```

If managing multiple subscriptions, select the one you want to use:

```sh
az account set --subscription "<subscription-id>"
```

## Usage

### 1️⃣ Import and Use in Python

```python
from manager import AzureKeyVaultManager

vault_url = "https://<your-key-vault-name>.vault.azure.net/"
key_vault_manager = AzureKeyVaultManager(vault_url)

# Create or update a secret
key_vault_manager.create_or_update_secret("my_secret", "MySecurePassword123!")

# Retrieve a secret
secret_value = key_vault_manager.get_secret("my_secret")
print(f"🔑 Secret value: {secret_value}")

# List secrets
secrets = key_vault_manager.list_secrets()
print(f"📋 List of secrets: {secrets}")

# Delete a secret
key_vault_manager.delete_secret("my_secret")

# Restore a deleted secret
key_vault_manager.restore_secret("my_secret")
```

### 2️⃣ CLI Usage

The tool includes a **CLI** for managing secrets from the terminal.

#### 🔹 Create or Update a Secret

```sh
./manager-cli.py create --name my_secret --value MySecurePassword123! --vault-url https://<your-key-vault-name>.vault.azure.net/
```

#### 🔹 Retrieve a Secret

```sh
./manager-cli.py get --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/
```

#### 🔹 List Secrets

```sh
./manager-cli.py list --vault-url https://<your-key-vault-name>.vault.azure.net/
```

#### 🔹 Delete a Secret

```sh
./manager-cli.py delete --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/
```

#### 🔹 Restore a Deleted Secret

```sh
./manager-cli.py restore --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/
```

## Notes

- This tool uses **Azure CLI authentication** to access **Azure Key Vault**.
- It only works with **Key Vaults enabled for deleted secret recovery**.
- It does not store credentials in the code; it uses secure authentication via **Azure Identity**.

## License

This project is licensed under the **MIT License**.


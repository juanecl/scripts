from azure.identity import AzureCliCredential
from azure.keyvault.secrets import SecretClient
from azure.core.exceptions import ResourceNotFoundError, HttpResponseError

class AzureKeyVaultManager:
    """
    Azure Key Vault Manager

    Usage example:
    key_vault_manager = AzureKeyVaultManager(vault_url="https://<your-key-vault-name>.vault.azure.net/")

    # Create or update a secret
    key_vault_manager.create_or_update_secret("my_secret", "MySecurePassword123!")

    # Get a secret
    secret_value = key_vault_manager.get_secret("my_secret")
    print(f"🔑 Secret value: {secret_value}")

    # List secrets
    secrets = key_vault_manager.list_secrets()
    print(f"📋 List of secrets: {secrets}")

    # Delete a secret
    key_vault_manager.delete_secret("my_secret")

    # Restore a deleted secret
    key_vault_manager.restore_secret("my_secret")
    """

    def __init__(self, vault_url):
        """
        Initializes the Azure Key Vault client.
        :param vault_url: URL of the Azure Key Vault.
        """
        self.client = SecretClient(vault_url=vault_url, credential=AzureCliCredential())

    def _handle_client_error(self, error, action):
        """
        Handles client errors and prints a formatted message.
        :param error: The exception raised.
        :param action: The action being performed when the error occurred.
        """
        if isinstance(error, ResourceNotFoundError):
            print(f"❌ The resource was not found during {action}.")
        else:
            print(f"⚠️ Error during {action}: {str(error)}")

    def create_or_update_secret(self, secret_name, secret_value):
        """
        Creates or updates a secret in Azure Key Vault.
        :param secret_name: Name of the secret.
        :param secret_value: Value of the secret.
        """
        try:
            response = self.client.set_secret(secret_name, secret_value)
            print(f"✅ The secret was created or updated: {response.id}")
        except HttpResponseError as e:
            self._handle_client_error(e, "creating or updating the secret")

    def get_secret(self, secret_name):
        """
        Retrieves the value of a secret.
        :param secret_name: Name of the secret.
        :return: Value of the secret or None if it does not exist.
        """
        try:
            response = self.client.get_secret(secret_name)
            return response.value
        except ResourceNotFoundError as e:
            self._handle_client_error(e, "retrieving the secret")
            return None
        except HttpResponseError as e:
            self._handle_client_error(e, "retrieving the secret")
            return None

    def delete_secret(self, secret_name):
        """
        Deletes a secret.
        :param secret_name: Name of the secret.
        """
        try:
            response = self.client.begin_delete_secret(secret_name).result()
            print(f"🗑️ The secret was deleted: {response.id}")
        except ResourceNotFoundError as e:
            self._handle_client_error(e, "deleting the secret")
        except HttpResponseError as e:
            self._handle_client_error(e, "deleting the secret")

    def list_secrets(self):
        """
        Lists all secrets stored in Azure Key Vault.
        :return: List of secret names.
        """
        try:
            secrets = []
            properties = self.client.list_properties_of_secrets()
            for secret_property in properties:
                secrets.append(secret_property.name)

            return secrets
        except HttpResponseError as e:
            self._handle_client_error(e, "listing the secrets")
            return []

    def restore_secret(self, secret_name):
        """
        Restores a deleted secret.
        :param secret_name: Name of the secret to restore.
        """
        try:
            response = self.client.begin_recover_deleted_secret(secret_name).result()
            print(f"♻️ The secret was restored: {response.id}")
        except ResourceNotFoundError as e:
            self._handle_client_error(e, "restoring the secret")
        except HttpResponseError as e:
            self._handle_client_error(e, "restoring the secret")
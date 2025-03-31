from google.cloud import secretmanager
from google.api_core.exceptions import NotFound, AlreadyExists

class GCPSecretManager:
    """
    GCP Secret Manager

    Usage example:
    secret_manager = GCPSecretManager(project_id="your-gcp-project-id")

    # Create or update a secret
    secret_manager.create_or_update_secret("my_secret", "MySecurePassword123!")

    # Get a secret
    secret_value = secret_manager.get_secret("my_secret")
    print(f"🔑 Secret value: {secret_value}")

    # List secrets
    secrets = secret_manager.list_secrets()
    print(f"📋 List of secrets: {secrets}")

    # Delete a secret
    secret_manager.delete_secret("my_secret")
    """

    def __init__(self, project_id):
        """
        Initializes the GCP Secret Manager client.
        :param project_id: GCP Project ID.
        """
        self.client = secretmanager.SecretManagerServiceClient()
        self.project_id = project_id

    def _handle_client_error(self, error, action):
        """
        Handles client errors and prints a formatted message.
        :param error: The exception raised.
        :param action: The action being performed when the error occurred.
        """
        if isinstance(error, NotFound):
            print(f"❌ The resource was not found during {action}.")
        elif isinstance(error, AlreadyExists):
            print(f"⚠️ The resource already exists during {action}.")
        else:
            print(f"⚠️ Error during {action}: {str(error)}")

    def create_or_update_secret(self, secret_name, secret_value):
        """
        Creates or updates a secret in GCP Secret Manager.
        :param secret_name: Name of the secret.
        :param secret_value: Value of the secret.
        """
        parent = f"projects/{self.project_id}"
        secret_id = f"{parent}/secrets/{secret_name}"

        try:
            # Try to create the secret
            self.client.create_secret(
                request={
                    "parent": parent,
                    "secret_id": secret_name,
                    "secret": {"replication": {"automatic": {}}},
                }
            )
            print(f"✅ The secret was created: {secret_id}")
        except AlreadyExists:
            print(f"⚠️ The secret already exists: {secret_id}")

        # Add a new version with the secret value
        try:
            payload = {"data": secret_value.encode("UTF-8")}
            response = self.client.add_secret_version(
                request={"parent": secret_id, "payload": payload}
            )
            print(f"✅ The secret version was added: {response.name}")
        except Exception as e:
            self._handle_client_error(e, "adding secret version")

    def get_secret(self, secret_name):
        """
        Retrieves the value of a secret.
        :param secret_name: Name of the secret.
        :return: Value of the secret or None if it does not exist.
        """
        secret_id = f"projects/{self.project_id}/secrets/{secret_name}/versions/latest"
        try:
            response = self.client.access_secret_version(request={"name": secret_id})
            return response.payload.data.decode("UTF-8")
        except NotFound as e:
            self._handle_client_error(e, "retrieving the secret")
            return None
        except Exception as e:
            self._handle_client_error(e, "retrieving the secret")
            return None

    def delete_secret(self, secret_name):
        """
        Deletes a secret.
        :param secret_name: Name of the secret.
        """
        secret_id = f"projects/{self.project_id}/secrets/{secret_name}"
        try:
            self.client.delete_secret(request={"name": secret_id})
            print(f"🗑️ The secret was deleted: {secret_id}")
        except NotFound as e:
            self._handle_client_error(e, "deleting the secret")
        except Exception as e:
            self._handle_client_error(e, "deleting the secret")

    def list_secrets(self):
        """
        Lists all secrets stored in GCP Secret Manager.
        :return: List of secret names.
        """
        parent = f"projects/{self.project_id}"
        try:
            secrets = []
            for secret in self.client.list_secrets(request={"parent": parent}):
                secrets.append(secret.name)
            return secrets
        except Exception as e:
            self._handle_client_error(e, "listing the secrets")
            return []
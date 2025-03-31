import boto3
import json
from botocore.exceptions import BotoCoreError, ClientError

class SecretsManagerClient:
    """
    AWS Secrets Manager Client

    Usage example:
    secrets_client = SecretsManagerClient(region="us-east-1", profile_name="secrets")

    # Create or update a secret
    secrets_client.create_or_update_secret("my_secret", "MySecurePassword123!")

    # Get a secret
    secret_value = secrets_client.get_secret("my_secret")
    print(f"🔑 Secret value: {secret_value}")

    # List secrets
    secrets = secrets_client.list_secrets()
    print(f"📋 List of secrets: {secrets}")

    # Delete a secret (with recovery)
    secrets_client.delete_secret("my_secret")

    # Restore a deleted secret
    secrets_client.restore_secret("my_secret")
    """

    def __init__(self, region="us-east-1", profile_name='default'):
        """
        Initializes the AWS Secrets Manager client.
        :param region: AWS region where the secrets are stored.
        :param profile_name: AWS CLI profile name to use.
        """
        session = boto3.Session(profile_name=profile_name)
        self.client = session.client("secretsmanager", region_name=region)

    def _handle_client_error(self, error, action):
        """
        Handles client errors and prints a formatted message.
        :param error: The exception raised.
        :param action: The action being performed when the error occurred.
        """
        if isinstance(error, self.client.exceptions.ResourceNotFoundException):
            print(f"❌ The resource was not found during {action}.")
        else:
            print(f"⚠️ Error during {action}: {str(error)}")

    def create_or_update_secret(self, secret_name, secret_value):
        """
        Creates or updates a secret in AWS Secrets Manager.
        :param secret_name: Name of the secret.
        :param secret_value: Value of the secret.
        """
        try:
            # Try to get the existing secret
            self.client.get_secret_value(SecretId=secret_name)
            print(f"🔄 The secret '{secret_name}' already exists. It will be updated...")
            
            response = self.client.update_secret(
                SecretId=secret_name,
                SecretString=json.dumps({"password": secret_value})
            )
            print(f"✅ The secret was updated: {response['ARN']}")

        except self.client.exceptions.ResourceNotFoundException:
            print(f"🆕 Creating the new secret '{secret_name}'...")

            response = self.client.create_secret(
                Name=secret_name,
                SecretString=json.dumps({"password": secret_value})
            )
            print(f"✅ The secret was created: {response['ARN']}")

        except (BotoCoreError, ClientError) as e:
            self._handle_client_error(e, "creating or updating the secret")

    def get_secret(self, secret_name):
        """
        Retrieves the value of a secret.
        :param secret_name: Name of the secret.
        :return: Value of the secret or None if it does not exist.
        """
        try:
            response = self.client.get_secret_value(SecretId=secret_name)
            secret_value = json.loads(response["SecretString"])
            return secret_value
        except (BotoCoreError, ClientError) as e:
            self._handle_client_error(e, "retrieving the secret")
            return None

    def delete_secret(self, secret_name, force_delete=False):
        """
        Deletes a secret with the option to permanently delete it.
        :param secret_name: Name of the secret.
        :param force_delete: If True, deletes the secret without a recovery period.
        """
        try:
            if force_delete:
                response = self.client.delete_secret(SecretId=secret_name, ForceDeleteWithoutRecovery=True)
                print(f"💀 The secret was permanently deleted: {secret_name}")
            else:
                response = self.client.delete_secret(SecretId=secret_name)
                print(f"🗑️ The secret was moved to deletion with recovery: {secret_name}")

            return response
        except (BotoCoreError, ClientError) as e:
            self._handle_client_error(e, "deleting the secret")

    def list_secrets(self):
        """
        Lists all secrets stored in AWS Secrets Manager.
        :return: List of secret names.
        """
        try:
            secrets = []
            response = self.client.list_secrets()
            for secret in response.get("SecretList", []):
                secrets.append(secret["Name"])

            return secrets
        except (BotoCoreError, ClientError) as e:
            self._handle_client_error(e, "listing the secrets")
            return []

    def restore_secret(self, secret_name):
        """
        Restores a secret that has been marked for deletion.
        :param secret_name: Name of the secret to restore.
        """
        try:
            response = self.client.restore_secret(SecretId=secret_name)
            print(f"♻️ The secret was restored: {response['ARN']}")
        except (BotoCoreError, ClientError) as e:
            self._handle_client_error(e, "restoring the secret")
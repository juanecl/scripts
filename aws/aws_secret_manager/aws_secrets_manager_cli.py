#!/usr/bin/env python3
import argparse
import json
from manager import SecretsManagerClient

def main():
    """
    Main function to handle AWS Secrets Manager operations via CLI.

    Usage:
    - Create a secret:
      ./manager-cli.py create --name my_secret --value MySecurePassword123!

    - Update a secret:
      ./manager-cli.py update --name my_secret --value MyNewSecurePassword456!

    - Get a secret:
      ./manager-cli.py get --name my_secret

    - List secrets:
      ./manager-cli.py list

    - Delete a secret:
      ./manager-cli.py delete --name my_secret

    - Force delete a secret without recovery:
      ./manager-cli.py delete --name my_secret --force

    - Restore a deleted secret:
      ./manager-cli.py restore --name my_secret

    Arguments:
    - action: The action to perform (create, update, get, list, delete, restore).
    - --name: The name of the secret.
    - --value: The value of the secret (required for create and update actions).
    - --force: Force delete without recovery (only for delete action).
    - --region: AWS region where the secrets are stored (default: us-east-1).
    - --profile: AWS CLI profile name to use (optional).
    """
    # Configuración del analizador de argumentos
    parser = argparse.ArgumentParser(description="AWS Secrets Manager CLI")
    parser.add_argument("action", choices=["create", "update", "get", "list", "delete", "restore"], help="Action to perform")
    parser.add_argument("--name", help="Name of the secret")
    parser.add_argument("--value", help="Value of the secret (required for create and update actions)")
    parser.add_argument("--force", action="store_true", help="Force delete without recovery (only for delete action)")
    parser.add_argument("--region", default="us-east-1", help="AWS region where the secrets are stored")
    parser.add_argument("--profile", help="AWS CLI profile name to use")

    # Parsear los argumentos de la línea de comandos
    args = parser.parse_args()

    # Inicializar el cliente de AWS Secrets Manager
    secrets_client = SecretsManagerClient(region=args.region, profile_name=args.profile)

    # Realizar la acción especificada
    if args.action in ["create", "update"]:
        # Verificar que los argumentos necesarios estén presentes
        if not args.name or not args.value:
            parser.error("The --name and --value arguments are required for create and update actions")
        # Crear o actualizar el secreto
        secrets_client.create_or_update_secret(args.name, args.value)
    elif args.action == "get":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the get action")
        # Obtener el valor del secreto
        secret_value = secrets_client.get_secret(args.name)
        if secret_value:
            print(f"🔑 Secret value: {secret_value}")
        else:
            print("❌ Secret not found")
    elif args.action == "list":
        # Listar todos los secretos
        secrets = secrets_client.list_secrets()
        print(f"📋 List of secrets: {secrets}")
    elif args.action == "delete":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the delete action")
        # Eliminar el secreto
        secrets_client.delete_secret(args.name, force_delete=args.force)
    elif args.action == "restore":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the restore action")
        # Restaurar el secreto
        secrets_client.restore_secret(args.name)

if __name__ == "__main__":
    main()
#!/usr/bin/env python3

import argparse
from manager import GCPSecretManager

def main():
    """
    Main function to handle GCP Secret Manager operations via CLI.

    Usage:
    - Create or update a secret:
      ./manager-cli.py create --name my_secret --value MySecurePassword123! --project-id your-gcp-project-id

    - Get a secret:
      ./manager-cli.py get --name my_secret --project-id your-gcp-project-id

    - List secrets:
      ./manager-cli.py list --project-id your-gcp-project-id

    - Delete a secret:
      ./manager-cli.py delete --name my_secret --project-id your-gcp-project-id

    Arguments:
    - action: The action to perform (create, get, list, delete).
    - --name: The name of the secret.
    - --value: The value of the secret (required for create action).
    - --project-id: The GCP Project ID.
    """
    # Configuración del analizador de argumentos
    parser = argparse.ArgumentParser(description="GCP Secret Manager CLI")
    parser.add_argument("action", choices=["create", "get", "list", "delete"], help="Action to perform")
    parser.add_argument("--name", help="Name of the secret")
    parser.add_argument("--value", help="Value of the secret (required for create action)")
    parser.add_argument("--project-id", required=True, help="GCP Project ID")

    # Parsear los argumentos de la línea de comandos
    args = parser.parse_args()

    # Inicializar el cliente de GCP Secret Manager
    secret_manager = GCPSecretManager(project_id=args.project_id)

    # Realizar la acción especificada
    if args.action == "create":
        # Verificar que los argumentos necesarios estén presentes
        if not args.name or not args.value:
            parser.error("The --name and --value arguments are required for the create action")
        # Crear o actualizar el secreto
        secret_manager.create_or_update_secret(args.name, args.value)
    elif args.action == "get":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the get action")
        # Obtener el valor del secreto
        secret_value = secret_manager.get_secret(args.name)
        if secret_value:
            print(f"🔑 Secret value: {secret_value}")
        else:
            print("❌ Secret not found")
    elif args.action == "list":
        # Listar todos los secretos
        secrets = secret_manager.list_secrets()
        print(f"📋 List of secrets: {secrets}")
    elif args.action == "delete":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the delete action")
        # Eliminar el secreto
        secret_manager.delete_secret(args.name)

if __name__ == "__main__":
    main()
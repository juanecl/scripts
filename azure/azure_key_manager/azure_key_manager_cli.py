#!/usr/bin/env python3

import argparse
from manager import AzureKeyVaultManager

def main():
    """
    Main function to handle Azure Key Vault operations via CLI.

    Usage:
    - Create or update a secret:
      ./manager-cli.py create --name my_secret --value MySecurePassword123! --vault-url https://<your-key-vault-name>.vault.azure.net/

    - Get a secret:
      ./manager-cli.py get --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/

    - List secrets:
      ./manager-cli.py list --vault-url https://<your-key-vault-name>.vault.azure.net/

    - Delete a secret:
      ./manager-cli.py delete --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/

    - Restore a deleted secret:
      ./manager-cli.py restore --name my_secret --vault-url https://<your-key-vault-name>.vault.azure.net/

    Arguments:
    - action: The action to perform (create, get, list, delete, restore).
    - --name: The name of the secret.
    - --value: The value of the secret (required for create action).
    - --vault-url: The URL of the Azure Key Vault.
    """
    # Configuración del analizador de argumentos
    parser = argparse.ArgumentParser(description="Azure Key Vault CLI")
    parser.add_argument("action", choices=["create", "get", "list", "delete", "restore"], help="Action to perform")
    parser.add_argument("--name", help="Name of the secret")
    parser.add_argument("--value", help="Value of the secret (required for create action)")
    parser.add_argument("--vault-url", required=True, help="URL of the Azure Key Vault")

    # Parsear los argumentos de la línea de comandos
    args = parser.parse_args()

    # Inicializar el cliente de Azure Key Vault
    key_vault_manager = AzureKeyVaultManager(vault_url=args.vault_url)

    # Realizar la acción especificada
    if args.action == "create":
        # Verificar que los argumentos necesarios estén presentes
        if not args.name or not args.value:
            parser.error("The --name and --value arguments are required for the create action")
        # Crear o actualizar el secreto
        key_vault_manager.create_or_update_secret(args.name, args.value)
    elif args.action == "get":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the get action")
        # Obtener el valor del secreto
        secret_value = key_vault_manager.get_secret(args.name)
        if secret_value:
            print(f"🔑 Secret value: {secret_value}")
        else:
            print("❌ Secret not found")
    elif args.action == "list":
        # Listar todos los secretos
        secrets = key_vault_manager.list_secrets()
        print(f"📋 List of secrets: {secrets}")
    elif args.action == "delete":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the delete action")
        # Eliminar el secreto
        key_vault_manager.delete_secret(args.name)
    elif args.action == "restore":
        # Verificar que el argumento necesario esté presente
        if not args.name:
            parser.error("The --name argument is required for the restore action")
        # Restaurar el secreto
        key_vault_manager.restore_secret(args.name)

if __name__ == "__main__":
    main()
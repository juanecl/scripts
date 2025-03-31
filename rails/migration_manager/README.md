# Rails Migration Manager

## Overview
The `rails_migration_manager.sh` script is a CLI tool designed to manage Rails database migrations efficiently. It verifies the presence of necessary dependencies, checks for a valid database configuration file, and runs pending migrations.

## Prerequisites
- **Ruby**: Ensure Ruby is installed on the system.
- **RubyGems**: Required for package management.
- **Rails**: The Rails framework must be installed.
- **Bundler**: Bundler should be installed to manage dependencies.

## Installation and Setup
1. Clone or download the script.
2. Grant execution permission:
   ```bash
   chmod +x rails_migration_manager.sh
   ```
3. Run the script with the appropriate options:
   ```bash
   ./rails_migration_manager.sh [-h|--help] [-d|--directory <app_directory>]
   ```

## Usage
```
rails_migration_manager.sh [-h|--help] [-d|--directory <app_directory>]
```

### Options
- **`-d, --directory <app_directory>`**: Specify the Rails application directory (defaults to the current directory).
- **`-h, --help`**: Display help information.

### Examples
#### Running the script in the current directory:
```bash
./rails_migration_manager.sh
```
#### Running the script for a specific Rails application directory:
```bash
./rails_migration_manager.sh -d /path/to/rails/app
```
#### Displaying help information:
```bash
./rails_migration_manager.sh -h
```

## Features
- **Checks Dependencies:** Ensures `ruby`, `gem`, `rails`, and `bundler` are installed.
- **Validates Configuration:** Confirms that `database.yml` exists in the specified Rails application directory.
- **Handles Missing Dependencies:** Attempts to install missing dependencies where possible.
- **Runs Pending Migrations:** Automatically detects and applies pending migrations.

## Logs and Troubleshooting
- If the script fails, check the following:
  - Ensure the Rails application directory exists.
  - Verify that `ruby` and `bundler` are installed.
  - Manually run:
    ```bash
    bundle exec rails db:migrate:status
    ```
    to check for pending migrations.
  - Inspect `log/development.log` for Rails-specific errors.

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
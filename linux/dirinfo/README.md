# Directory Information Script

## Overview
The `dirinfo.sh` script is a CLI tool that analyzes a directory and provides information about its subdirectories in either a human-readable format or JSON.

## Prerequisites
- **Bash**: Ensure you are running the script in a Bash-compatible environment.
- **jq (Optional)**: If JSON output is requested, `jq` must be installed.

## Installation and Setup
1. Download or create the script.
2. Grant execution permission:
   ```bash
   chmod +x dirinfo.sh
   ```
3. Run the script with the desired options:
   ```bash
   ./dirinfo.sh [-j|--json] <directory> <depth>
   ```

## Usage
```
dirinfo.sh [-j|--json] <directory> <depth>
```

### Arguments
- **`-j, --json`**: Output the results in JSON format.
- **`<directory>`**: The directory to analyze (default: current directory `.`).
- **`<depth>`**: The maximum depth to traverse (default: `1`).

### Examples
#### Analyze the current directory with depth 2 (human-readable output):
```bash
./dirinfo.sh . 2
```
#### Analyze a specific directory and output results in JSON format:
```bash
./dirinfo.sh -j /path/to/directory 3
```

## Features
- **Provides details for each subdirectory**, including:
  - Name
  - Owner
  - Group
  - Size
  - Numeric permissions
  - Symbolic permissions
- **Supports JSON output** for easy integration with other tools.
- **Uses color formatting** for improved readability in human-readable output.

## Logs and Troubleshooting
- If the directory does not exist, an error message is displayed.
- If JSON output is requested but `jq` is not installed, an error is thrown.
- Use `find` manually to verify directory structure:
  ```bash
  find /path/to/directory -maxdepth 2 -type d
  ```

## License
This script is provided as-is without warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl

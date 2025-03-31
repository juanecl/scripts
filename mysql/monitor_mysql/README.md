# MySQL/MariaDB Monitoring Script

## Overview
This Bash script monitors the performance and health of a MySQL/MariaDB database by checking its status, retrieving server statistics, and calculating database size.

## Features
- ✅ Checks MySQL/MariaDB server status
- 📊 Retrieves MySQL/MariaDB server statistics
- 📂 Calculates database size
- 🕒 Can be scheduled using `cron` for periodic monitoring

## Prerequisites
- MySQL or MariaDB installed on the server
- User with appropriate database privileges
- Bash environment

## Installation
Clone or download the script to your preferred directory:
```bash
wget https://gist.github.com/juanecl/3e1017fad42d473b1d60d5a245922fa8
chmod +x monitor.sh
```

## Usage
### Running the Script
Execute the script using the following command:
```bash
./monitor.sh -u <db_user> -p <db_password> -h <db_host> -P <db_port> <db_name>
```

### Example
```bash
./monitor.sh -u root -p mypassword -h localhost -P 3306 mydatabase
```

### Example `cron` Job (Every 5 Minutes)
To automate the monitoring process, add the following line to your `crontab`:
```bash
*/5 * * * * /bin/bash /path/to/monitor.sh -u root -p mypassword -h localhost -P 3306 mydatabase
```

## Script Functions
- **`execute_mysql_command`**: Runs MySQL queries.
- **`execute_mysqladmin_command`**: Executes MySQL admin commands.
- **`check_mysql_status`**: Checks if the MySQL/MariaDB server is running.
- **`get_mysql_stats`**: Retrieves MySQL/MariaDB server performance statistics.
- **`get_mysql_db_size`**: Calculates the size of a given database.

## Output
The script outputs:
- Server status confirmation
- Key performance statistics
- Database size in MB

## Error Handling
If any required arguments are missing, the script displays usage instructions and exits.

## License
This script is open-source and provided as a **Gist**, not a full repository.

## Author
Juan Enrique Chomon Del Campo

## Contributions
Feel free to suggest improvements or enhancements!

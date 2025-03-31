# chmod Converter Script

## Overview
This Bash script provides an easy way to convert between numeric and symbolic `chmod` permissions. It also supports abbreviated symbolic notation and retrieving a file's current permissions.

## Prerequisites
- A Unix-based system with `bash` installed.
- Ensure the script has execute permissions:
  ```bash
  chmod +x chmod_converter.sh
  ```

## Installation and Usage
Run the script with one of the following options:
```bash
./chmod_converter.sh [-n <num>] [-s <sym>] [-a <abbr>] [-f <file>]
```

### Options
- **`-n <numeric>`**: Convert numeric permissions to symbolic.
- **`-s <symbolic>`**: Convert symbolic permissions to numeric.
- **`-a <abbr>`**: Convert abbreviated symbolic notation to `chmod` command.
- **`-f <file>`**: Retrieve a file’s permissions in numeric format.

### Examples
#### Convert numeric to symbolic
```bash
./chmod_converter.sh -n 755
```
Output:
```
Numeric Permissions : 755
Symbolic Permissions: rwxr-xr-x
Suggested Command : chmod u=rwx,g=rx,o=rx <file/dir>
```

#### Convert symbolic to numeric
```bash
./chmod_converter.sh -s rwxr-xr-x
```
Output:
```
Symbolic Permissions: rwxr-xr-x
Numeric Permissions : 755
Suggested Command : chmod 755 <file/dir>
```

#### Convert abbreviated symbolic notation
```bash
./chmod_converter.sh -a +x
```
Output:
```
Abbreviated Symbolic: +x
Suggested Command : chmod <who>+x <file/dir> (who=u/g/o/a)
```

#### Retrieve file permissions
```bash
./chmod_converter.sh -f /path/to/file
```
Output:
```
File : /path/to/file
Symbolic Permissions: rw-r--r--
Numeric Permissions : 644
```

## Error Handling
- If an invalid numeric or symbolic format is provided, an error message is displayed.
- If the file does not exist, the script exits with an error message.

## License
This script is provided as-is without any warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl

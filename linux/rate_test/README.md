# Rate Test Script

## Overview
The `rate_test.sh` script sends a specified number of HTTP requests to a given URL, displaying a loader animation while requests are in progress. When complete, it outputs the HTTP status codes and their counts in a concise format.

## Usage
```bash
./rate_test.sh <url> <requests>
```

### Example
```bash
./rate_test.sh https://example.com 100
```

## Requirements
- **curl**: Used to send HTTP requests.
- **bc**: Used to perform basic math operations.
- **grep / awk**: For validating input and processing output.

## How it Works
1. **Input Validation**:
   - Checks that `<url>` matches the `https?://` pattern.
   - Ensures `<requests>` is a number between `1` and `5000`.
2. **Parallel Requests**:
   - Distributes the total requests over 60 seconds, resulting in a certain number of requests/second (e.g., `seq | xargs -n1 -P...`).
3. **Loader Animation**:
   - Displays a simple spinner until all background requests have completed.
4. **Result Output**:
   - Groups and counts HTTP status codes.
   - Highlights server errors (`5xx`) in red.

## Options & Arguments
| Argument    | Description                                                                      |
|-------------|----------------------------------------------------------------------------------|
| `<url>`     | The URL to send requests to (must start with http:// or https://).               |
| `<requests>`| Number of requests to send (integer from 1 to 5000).                             |

## Examples
### Send 100 requests to a URL:
```bash
./rate_test.sh https://example.com 100
```

## Troubleshooting
- **Invalid URL**:
  - Check that the URL is correctly formatted with `http://` or `https://`.
- **Invalid Number of Requests**:
  - Ensure the requests value is between 1 and 5000.
- **Curl / BC Not Installed**:
  - Install these packages:
    ```bash
    sudo apt install curl bc -y      # Debian/Ubuntu
    sudo yum install curl bc -y      # RHEL/CentOS
    brew install curl bc            # macOS
    ```

## License
This script is provided as-is without any warranties. Use at your own risk.

## Author
- **Juan Enrique Chomon Del Campo**
- **Email**: hola@juane.cl
# SVN Merge Script

## Overview
This Bash script automates the process of merging an SVN trunk with a specified branch. It authenticates the user, checks out the repositories, and prepares for merging. The script requires two parameters: the full URL of the trunk and the full URL of the branch.

## Prerequisites
- Ensure you have `svn` installed and configured on your system.
- Replace the `SVN_PASS` variable with your SVN password or use an authentication method that does not require storing passwords in plain text.

## Installation and Setup
1. Download or create the `svn_merge.sh` script.
2. Grant execution permission:
   ```bash
   chmod +x svn_merge.sh
   ```
3. Run the script with the trunk and branch URLs:
   ```bash
   ./svn_merge.sh {trunk_url} {branch_url}
   ```
   Example:
   ```bash
   ./svn_merge.sh https://svn.example.com/repo/trunk https://svn.example.com/repo/branches/feature-branch
   ```

## Script Functionality
1. **Authenticates the SVN user**: Uses credentials to authenticate the SVN session.
2. **Creates a temporary directory**: Stores temporary files related to the merge.
3. **Checks the existence of SVN URLs**: Validates that both trunk and branch exist.
4. **Checks out the trunk**: Downloads the trunk repository to the local system.
5. **Prepares for merging**: Additional logic can be added to handle conflicts and commit changes.

## Environment Variables
- **TMP_DIR**: Temporary directory where the merge process is handled.
- **SVN_USER**: Defaults to the current system user.
- **SVN_PASS**: Needs to be manually set or use an alternative authentication method.

## Logs
- The script outputs messages indicating the progress and success/failure of each step.
- Any issues with authentication or missing SVN repositories are reported.

## Security Considerations
- Storing passwords in scripts is insecure. Consider using `svn --config-dir` for secure authentication.
- Use SSH keys or credential caching for a more secure approach.

## Troubleshooting
- Ensure the provided SVN URLs are correct and accessible.
- Run `svn info {url}` manually to verify repository access.
- Check SVN logs if the checkout or authentication fails.

## License
This script is provided as-is without any warranties. Use at your own risk.

## Author
- **Juane Chomon**
- **Email**: hola@juane.cl

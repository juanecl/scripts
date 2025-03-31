   #!/bin/bash
 

 # Define color codes (may not work on all terminals)
 RED='\033[0;31m'
 GREEN='\033[0;32m'
 YELLOW='\033[0;33m'
 NC='\033[0m' # No Color
 

 ################################################################################
 # Script: chmod_converter.sh
 # Description: Converts between numeric and symbolic chmod permissions.
 # Usage: ./chmod_converter.sh [-n <num>] [-s <sym>] [-a <abbr>] [-f <file>]
 ################################################################################
 

 #------------------------------------------------------------------------------
 # Function: check_command_installed
 # Checks if a command is installed.
 #------------------------------------------------------------------------------
 check_command_installed() {
  if ! command -v "$1" &> /dev/null; then
  echo -e "${RED}Error: '$1' is not installed. Please install it to proceed.${NC}" >&2
  return 1
  fi
  return 0
 }
 

 #------------------------------------------------------------------------------
 # Function: numeric_to_symbolic
 # Converts numeric permissions to symbolic.
 #------------------------------------------------------------------------------
 numeric_to_symbolic() {
  local numeric="$1"
 

  # Validate input
  if ! [[ "$numeric" =~ ^[0-7]{3,4}$ ]]; then
  echo -e "${RED}Error: Invalid numeric permissions. Must be 3 or 4 digits (0-7).${NC}" >&2
  return 1
  fi
 

  local owner=$((numeric / 100 % 8))
  local group=$((numeric / 10 % 10))
  local other=$((numeric % 10))
 

  local symbolic=""
 

  # Determine permissions
  symbolic+=$([ "$owner" -ge 4 ] && echo "r" || echo "-")
  symbolic+=$([ "$owner" -ge 2 ] && echo "w" || echo "-")
  symbolic+=$([ "$owner" -ge 1 ] && echo "x" || echo "-")
  symbolic+=$([ "$group" -ge 4 ] && echo "r" || echo "-")
  symbolic+=$([ "$group" -ge 2 ] && echo "w" || echo "-")
  symbolic+=$([ "$group" -ge 1 ] && echo "x" || echo "-")
  symbolic+=$([ "$other" -ge 4 ] && echo "r" || echo "-")
  symbolic+=$([ "$other" -ge 2 ] && echo "w" || echo "-")
  symbolic+=$([ "$other" -ge 1 ] && echo "x" || echo "-")
 

  # Output results
  echo "--------------------------------------------------"
  echo "Numeric Permissions : $numeric"
  echo "Symbolic Permissions: $symbolic"
  printf "${GREEN}Suggested Command : chmod <who>=$symbolic <file/dir>${NC}\n"
  echo "--------------------------------------------------"
 }
 

 #------------------------------------------------------------------------------
 # Function: symbolic_to_numeric
 # Converts symbolic permissions to numeric.
 #------------------------------------------------------------------------------
 symbolic_to_numeric() {
  local symbolic="$1"
 

  # Validate input
  if ! [[ "$symbolic" =~ ^[rwx-]{9}$ ]]; then
  echo -e "${RED}Error: Invalid symbolic permissions. Must be 9 chars (rwx-).${NC}" >&2
  return 1
  fi
 

  local owner=0
  local group=0
  local other=0
 

  # Determine values
  [[ "${symbolic:0:1}" == "r" ]] && owner=$((owner + 4))
  [[ "${symbolic:1:1}" == "w" ]] && owner=$((owner + 2))
  [[ "${symbolic:2:1}" == "x" ]] && owner=$((owner + 1))
  [[ "${symbolic:3:1}" == "r" ]] && group=$((group + 4))
  [[ "${symbolic:4:1}" == "w" ]] && group=$((group + 2))
  [[ "${symbolic:5:1}" == "x" ]] && group=$((group + 1))
  [[ "${symbolic:6:1}" == "r" ]] && other=$((other + 4))
  [[ "${symbolic:7:1}" == "w" ]] && other=$((other + 2))
  [[ "${symbolic:8:1}" == "x" ]] && other=$((other + 1))
 

  local numeric="$owner$group$other"
 

  # Output results
  echo "--------------------------------------------------"
  echo "Symbolic Permissions: $symbolic"
  echo "Numeric Permissions : $numeric"
  printf "${GREEN}Suggested Command : chmod $numeric <file/dir>${NC}\n"
  echo "--------------------------------------------------"
 }
 

 #------------------------------------------------------------------------------
 # Function: abbreviated_symbolic_to_chmod
 # Handles abbreviated symbolic notation (e.g., +x, -w).
 #------------------------------------------------------------------------------
 abbreviated_symbolic_to_chmod() {
  local symbolic="$1"
 

  # Validate input
  if ! [[ "$symbolic" =~ ^[+-][rwx]+$ ]]; then
  echo -e "${RED}Error: Invalid abbreviated symbolic permissions (+/- followed by rwx).${NC}" >&2
  return 1
  fi
 

  # Output suggestion
  echo "--------------------------------------------------"
  echo "Abbreviated Symbolic: $symbolic"
  printf "${GREEN}Suggested Command : chmod <who>$symbolic <file/dir> (who=u/g/o/a)${NC}\n"
  echo "--------------------------------------------------"
 }
 

 #------------------------------------------------------------------------------
 # Function: file_to_numeric
 # Converts file's symbolic permissions to numeric.
 #------------------------------------------------------------------------------
 file_to_numeric() {
  local file_path="$1"
 

  # Check if the file exists
  if [ ! -e "$file_path" ]; then
  echo -e "${RED}Error: File '$file_path' does not exist.${NC}" >&2
  return 1
  fi
 

  # Get symbolic permissions
  local ls_output=$(ls -l "$file_path")
  local symbolic_permissions=$(echo "$ls_output" | awk '{print substr($1, 2, 9)}')
 

  # Output file information
  echo "--------------------------------------------------"
  echo "File : $file_path"
 

  # Convert and output
  symbolic_to_numeric "$symbolic_permissions"
  echo "--------------------------------------------------"
 }
 

 #------------------------------------------------------------------------------
 # Function: show_usage
 # Displays script usage information.
 #------------------------------------------------------------------------------
 show_usage() {
  echo "Usage: $0 [-n <num>] [-s <sym>] [-a <abbr>] [-f <file>]" >&2
  echo " -n <numeric> : Convert numeric -> symbolic" >&2
  echo " -s <symbolic> : Convert symbolic -> numeric" >&2
  echo " -a <abbr> : Abbreviated symbolic notation" >&2
  echo " -f <file> : File's permissions to numeric" >&2
  echo "Example: $0 -n 755" >&2
  echo " $0 -s rwxr-xr-x" >&2
  echo " $0 -a +x" >&2
  echo " $0 -f /path/to/file" >&2
 }
 

 #------------------------------------------------------------------------------
 # Main Script Logic
 #------------------------------------------------------------------------------
 

 # Check for arguments
 if [ $# -eq 0 ]; then
  show_usage
  exit 1
 fi
 

 # Initialize variables
 NUMERIC=""
 SYMBOLIC=""
 ABBREV=""
 FILE_PATH=""
 

 # Process command-line options
 while [[ $# -gt 0 ]]; do
  case "$1" in
  -n)
  if [[ $# -gt 1 ]]; then
  NUMERIC="$2"
  shift 2
  else
  echo -e "${RED}Error: Option '-n' requires an argument.${NC}" >&2
  show_usage
  exit 1
  fi
  ;;
  -s)
  if [[ $# -gt 1 ]]; then
  SYMBOLIC="$2"
  shift 2
  else
  echo -e "${RED}Error: Option '-s' requires an argument.${NC}" >&2
  show_usage
  exit 1
  fi
  ;;
  -a)
  if [[ $# -gt 1 ]]; then
  ABBREV="$2"
  shift 2
  else
  echo -e "${RED}Error: Option '-a' requires an argument.${NC}" >&2
  show_usage
  exit 1
  fi
  ;;
  -f|--file)
  if [[ $# -gt 1 ]]; then
  FILE_PATH="$2"
  shift 2
  else
  echo -e "${RED}Error: Option '-f' requires an argument.${NC}" >&2
  show_usage
  exit 1
  fi
  ;;
  *)
  echo -e "${RED}Error: Invalid option: '$1'${NC}" >&2
  show_usage
  exit 1
  ;;
  esac
 done
 

 # Perform actions
 if [ -n "$NUMERIC" ]; then
  numeric_to_symbolic "$NUMERIC"
 elif [ -n "$SYMBOLIC" ]; then
  symbolic_to_numeric "$SYMBOLIC"
 elif [ -n "$ABBREV" ]; then
  abbreviated_symbolic_to_chmod "$ABBREV"
 elif [ -n "$FILE_PATH" ]; then
  file_to_numeric "$FILE_PATH"
 else
  echo -e "${RED}Error: No valid options provided.${NC}" >&2
  show_usage
  exit 1
 fi
 

 exit 0
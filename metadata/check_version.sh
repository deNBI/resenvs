
FUNCTION_KEY="$1"
SCRIPT_VERSION="$2"
METADATA_VERSION="$3"

# Path to the compatibility JSON file
COMPATIBILITY_FILE="config/compatibility.json"

# Function to check version compatibility
check_version() {
  local function_key=$1
  local script_version=$2
  local metadata_version=$3

  # Read the JSON file and extract the list of compatible versions for the function key and script version
  compatible_versions=$(jq -r --arg function_key "$function_key" --arg script_version "$script_version" \\
    '.[$function_key][$script_version][]' "$COMPATIBILITY_FILE")

  # Check if the metadata version is in the list of compatible versions
  for version in $compatible_versions; do
    if [[ "$version" == "$metadata_version" ]]; then
      return 0  # true
    fi
  done

  return 1  # false
}

# Check if compatibility file exists
if [ ! -f "$COMPATIBILITY_FILE" ]; then
  echo "Compatibility file not found: $COMPATIBILITY_FILE"
  exit 1
fi

# Perform the version check
check_version "$FUNCTION_KEY" "$SCRIPT_VERSION" "$METADATA_VERSION"

# Capture the result of the check_version function
if [ $? -eq 0 ]; then
  echo "Versions are compatible."
else
  echo "Versions are not compatible."
fi
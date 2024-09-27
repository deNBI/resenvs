#!/bin/bash

# Load the key, script version, and metadata version from arguments
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
    '.[$function_key][$script_version] // empty' "$COMPATIBILITY_FILE")

  # Check if the metadata version is in the list of compatible versions
  if echo "$compatible_versions" | grep -q "$metadata_version"; then
    return 0  # true
  else
    return 1  # false
  fi
}

check_version "$FUNCTION_KEY" "$SCRIPT_VERSION" "$METADATA_VERSION"
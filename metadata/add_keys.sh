  #!/bin/bash

  # Path to the log file
  LOG_FILE="/var/log/metadata.log"

  # Function to log messages with timestamps
  log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
  }

  # Load the auth token and user from .metadata_config.env
  source metadata_config.env

  # Set default user to 'ubuntu' if not provided
  USER_TO_SET="${USER_TO_SET:-ubuntu}"
  USER_HOME=$(eval echo "~$USER_TO_SET")

  # Step 1: Run the get_metadata script and capture its output
  log_message "Getting metadata from server"
  response=$(./get_metadata.sh)

  # Log the JSON response for debugging purposes
  log_message "Response from get_metadata.sh: $response"

  # Check if the response is valid JSON
  if ! echo "$response" | jq . >/dev/null 2>&1; then
    log_message "Invalid JSON response. Exiting."
    exit 1
  fi

  # Extract public_keys from the nested JSON structure
  public_keys=$(echo "$response" | jq -r '.userdata.data[] | .public_keys[]?')

  # Check if public_keys is empty
  if [ -z "$public_keys" ]; then
    log_message "No public keys found. metadata_authorized_keys file not updated."
    exit 0
  fi

  # Ensure the .ssh directory and metadata_authorized_keys file exist
  mkdir -p "$USER_HOME/.ssh"
  touch "$USER_HOME/.ssh/metadata_authorized_keys"

  # Set the correct permissions for the .ssh directory and its contents
  chown -R $USER_TO_SET:$USER_TO_SET "$USER_HOME/.ssh"

  # Function to check if a key already exists in the metadata_authorized_keys file
  key_exists() {
    grep -Fqx "$1" "$USER_HOME/.ssh/metadata_authorized_keys"
  }

  # Add keys to metadata_authorized_keys if they don't already exist
  added_keys=0

  while IFS= read -r key; do
    if ! key_exists "$key"; then
      echo "$key" >> "$USER_HOME/.ssh/metadata_authorized_keys"
      ((added_keys++))
    fi
  done <<< "$public_keys"

  # Set the correct permissions for the metadata_authorized_keys file
  chown $USER_TO_SET:$USER_TO_SET "$USER_HOME/.ssh/metadata_authorized_keys"

  if [ $added_keys > 0 ]; then
    log_message "$added_keys new public key(s) have been added to the metadata_authorized_keys file."
  else
    log_message "All public keys were already present. No changes made to metadata_authorized_keys file."
  fi

  log_message "Script execution completed"

  # make sure that the authorized keys file for the corresponding user is set
  # set it in sshd config by: 
  # AuthorizedKeysFile      .ssh/authorized_keys /home/%u/.ssh/authorized_keys /home/%u/.ssh/metadata_authorized_keys
  # currently this file works when executed by hand - why is it not finding keys when
  # executed by the service?
  # the usernames we have as keys might be a problem --> cannot add users with such identifiers

#!/bin/bash

# Define the paths for log file and password file
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.csv"

# create directories and files, then assign appropriate permissions
sudo mkdir -p /var/log
sudo mkdir -p /var/secure
sudo touch "$LOG_FILE"
sudo touch "$PASSWORD_FILE"
sudo chmod 600 "$PASSWORD_FILE"

# A function to generate random password
generate_password() {
  < /dev/urandom tr -dc 'A-Za-z0-9!@#$%&*' | head -c 16
}

# Read the input file
while IFS=";" read -r username groups; do
  # eliminate whitespace
  username=$(echo "$username" | xargs)
  groups=$(echo "$groups" | xargs)

  # Create a user group, then a primary group using username
  if ! getent group "$username" > /dev/null; then
    sudo groupadd "$username"
    echo "$(date): Group $username created" | sudo tee -a "$LOG_FILE"
  else
    echo "$(date): Group $username already exists" | sudo tee -a "$LOG_FILE"
  fi

  # Create user if it doesn't exist
  if ! id -u "$username" > /dev/null 2>&1; then
    sudo useradd -m -g "$username" -G "$groups" "$username"
    password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    echo "$(date): User $username created with groups $groups" | sudo tee -a "$LOG_FILE"
    echo "$username,$password" | sudo tee -a "$PASSWORD_FILE"
    sudo chown root:root "$PASSWORD_FILE"
  else
    echo "$(date): User $username already exists" | sudo tee -a "$LOG_FILE"
  fi

  # Create additional groups
  IFS=',' read -ra ADDR <<< "$groups"
  for group in "${ADDR[@]}"; do
    if ! getent group "$group" > /dev/null; then
      sudo groupadd "$group"
      echo "$(date): Group $group created" | sudo tee -a "$LOG_FILE"
    fi
    sudo usermod -aG "$group" "$username"
    echo "$(date): User $username added to group $group" | sudo tee -a "$LOG_FILE"
  done

  # Set permissions for home directory
  sudo chmod 700 "/home/$username"
  sudo chown "$username:$username" "/home/$username"

done < "$1"

echo "User creation process completed."

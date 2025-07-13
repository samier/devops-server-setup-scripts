#!/bin/bash

# Usage: sudo ./add_ssh_user.sh <username> <public_key_file_or_string>
# Usage: sudo ./add_ssh_user.sh newuser "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC..."

USERNAME="$1"
PUBKEY_INPUT="$2"

if [[ -z "$USERNAME" || -z "$PUBKEY_INPUT" ]]; then
  echo "Usage: $0 <username> <public_key_file_or_string>"
  echo "  <public_key_file_or_string>: Path to public key file or the public key string itself"
  exit 1
fi

# Add the user without a password and without prompting for details
sudo adduser --disabled-password --gecos "" "$USERNAME"

# Create .ssh directory and set permissions
sudo mkdir -p /home/"$USERNAME"/.ssh
sudo chmod 700 /home/"$USERNAME"/.ssh
sudo chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh

# Determine if PUBKEY_INPUT is a file or a string
if [[ -f "$PUBKEY_INPUT" ]]; then
  PUBKEY=$(cat "$PUBKEY_INPUT")
else
  PUBKEY="$PUBKEY_INPUT"
fi

# Add the public key to authorized_keys
echo "$PUBKEY" | sudo tee /home/"$USERNAME"/.ssh/authorized_keys > /dev/null
sudo chmod 600 /home/"$USERNAME"/.ssh/authorized_keys
sudo chown "$USERNAME":"$USERNAME" /home/"$USERNAME"/.ssh/authorized_keys

# Add user to docker group
  sudo usermod -aG docker "$USERNAME"

echo "User '$USERNAME' created with SSH key authentication only (no password set)."
echo "You can now log in as $USERNAME using your SSH key."

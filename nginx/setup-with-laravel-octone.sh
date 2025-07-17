#!/bin/bash

set -e

# Get the logged-in (non-root, non-sudo) user
REAL_USER=$(logname)
USER_HOME=$(eval echo "~$REAL_USER")
VHOST_NAME="$REAL_USER.local"
LARAVEL_ROOT="$USER_HOME/classcare_2.0"
PUBLIC_ROOT="$LARAVEL_ROOT/public"

echo "Detected non-root user: $REAL_USER"
echo "Setting up virtual host: $VHOST_NAME"
echo "Laravel/Angular root: $LARAVEL_ROOT"
echo "Public (Angular build): $PUBLIC_ROOT"

# 1. Install required packages
sudo apt update
sudo apt install -y curl gnupg2 ca-certificates lsb-release ufw

# 2. Import the official NGINX signing key
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

# 3. Add the NGINX APT repository
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" \
  | sudo tee /etc/apt/sources.list.d/nginx.list

# 4. Update package lists and install NGINX
sudo apt update
sudo apt install -y nginx

# 5. Start and enable NGINX service
sudo systemctl enable nginx
sudo systemctl start nginx

# 6. Firewall: Allow HTTP, HTTPS, SSH
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw --force enable
sudo ufw status verbose

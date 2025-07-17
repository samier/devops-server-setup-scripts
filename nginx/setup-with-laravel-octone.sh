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

# 7. --- Laravel/Angular Setup Directories ---
#sudo mkdir -p "$PUBLIC_ROOT"
#sudo chown -R "$REAL_USER":"$REAL_USER" "$LARAVEL_ROOT"

# 8. Add a test file in public just in case
echo "<h1>Hello from $VHOST_NAME - NGINX reverse proxy for Laravel/Octane with Angular</h1>" | sudo tee "$PUBLIC_ROOT/index.html"

# 9. --- Create the NGINX server block (virtual host for reverse proxy) ---
VHOST_CONF="/etc/nginx/conf.d/$VHOST_NAME.conf"
sudo tee "$VHOST_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $VHOST_NAME;

    # Serve Angular build (static files) from public folder
    root $PUBLIC_ROOT;
    index index.html index.htm;

    access_log /var/log/nginx/${VHOST_NAME}_access.log;
    error_log /var/log/nginx/${VHOST_NAME}_error.log;

    location /app {
        #try_files $uri $uri/ $uri.html $uri.php =404;
       try_files $uri @rewriteappangular;
    }

    location @rewriteappangular {
        rewrite ^(.*)$ /app/index.html last;
    }
    
    location @octane {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_http_version 1.1;
        proxy_set_header Connection "";
        proxy_buffering off;
    }

}
EOF

# 10. Reload NGINX to apply changes
sudo nginx -t && sudo systemctl reload nginx

nginx -v

echo ""
echo "Virtual host $VHOST_NAME (reverse proxy + static) configured!"
echo "Add to your /etc/hosts for local testing:"
echo "127.0.0.1   $VHOST_NAME"
echo "Start your Laravel Octane server on 127.0.0.1:8000 for reverse proxy to work"
echo "Deploy your Angular build to: $PUBLIC_ROOT"
echo "Then browse to http://$VHOST_NAME"

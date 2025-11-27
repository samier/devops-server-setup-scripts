# Create directory for n8n
mkdir ~/n8n-docker
cd ~/n8n-docker

# Create directories for persistent data
mkdir -p .n8n
mkdir -p letsencrypt

# Set proper permissions
chmod 600 letsencrypt

# Fix permissions
sudo chown -R 1000:1000 .n8n/
sudo chmod -R 755 .n8n/

# Check DNS resolution
nslookup yourdomain.com
dig yourdomain.com

# Start all services
docker-compose up -d

# Check if containers are running
docker-compose ps

# Stop services
docker-compose down

# Update n8n to latest version
docker-compose pull
docker-compose up -d

# View real-time logs
docker-compose logs -f

# Access n8n container shell
docker-compose exec n8n /bin/sh

# Restart specific service
docker-compose restart n8n

# Configure firewall
sudo ufw allow 22/tcp

sudo ufw allow 80/tcp

sudo ufw allow 443/tcp

sudo ufw allow 5678/tcp

sudo ufw enable

sudo ufw enable

ufw reload

ufw status

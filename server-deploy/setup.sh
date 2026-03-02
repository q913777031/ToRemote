#!/bin/bash
# ToRemote Server Deployment Script
# Run this on your Ubuntu 22.04 cloud server

set -e

echo "=== ToRemote Server Setup ==="
echo ""

# Install Docker
echo "[1/4] Installing Docker..."
sudo apt update && sudo apt install -y docker.io docker-compose

# Create directory
echo "[2/4] Setting up server directory..."
mkdir -p ~/toremote-server/data
cp docker-compose.yml ~/toremote-server/

# Start services
echo "[3/4] Starting RustDesk Server..."
cd ~/toremote-server
sudo docker-compose up -d

# Wait for key generation
echo "[4/4] Waiting for key generation..."
sleep 3

# Display results
echo ""
echo "=== Setup Complete ==="
echo ""
echo "Server IP: $(curl -s ifconfig.me 2>/dev/null || echo '<check manually>')"
echo ""

if [ -f ~/toremote-server/data/id_ed25519.pub ]; then
    echo "Public Key:"
    cat ~/toremote-server/data/id_ed25519.pub
    echo ""
    echo ""
    echo "Save these two values! You need them for the client configuration."
else
    echo "Key file not found yet. Run this to get it later:"
    echo "  cat ~/toremote-server/data/id_ed25519.pub"
fi

echo ""
echo "Required firewall ports (open in cloud console):"
echo "  21115/tcp  - NAT type test"
echo "  21116/tcp  - ID registration"
echo "  21116/udp  - Heartbeat/hole punching"
echo "  21117/tcp  - Relay traffic"
echo "  21118/tcp  - Web client (optional)"
echo "  21119/tcp  - Web client (optional)"
echo ""
echo "To check server status:  sudo docker-compose ps"
echo "To view logs:            sudo docker-compose logs -f"
echo "To restart:              sudo docker-compose restart"

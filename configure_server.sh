#!/bin/bash
# ToRemote Server Configuration Script
# Usage: ./configure_server.sh <SERVER_IP> <PUBLIC_KEY>
#
# This script patches the source code with your server's IP and public key.
# Run this after deploying RustDesk Server and obtaining your id_ed25519.pub key.

set -e

if [ $# -ne 2 ]; then
    echo "Usage: $0 <SERVER_IP> <PUBLIC_KEY>"
    echo ""
    echo "Example:"
    echo "  $0 123.45.67.89 OeVuKk5nlHiXp+APNn0Y3pC1Iwpwn44JGqrQCsWqmBw="
    echo ""
    echo "Get these values from your cloud server:"
    echo "  SERVER_IP  = Your server's public IP address"
    echo "  PUBLIC_KEY = Content of ~/toremote-server/data/id_ed25519.pub"
    exit 1
fi

SERVER_IP="$1"
PUBLIC_KEY="$2"

CONFIG_FILE="libs/hbb_common/src/config.rs"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: $CONFIG_FILE not found."
    echo "Make sure you run this script from the repository root directory."
    exit 1
fi

echo "=== ToRemote Server Configuration ==="
echo ""
echo "Server IP:  $SERVER_IP"
echo "Public Key: $PUBLIC_KEY"
echo ""

# Patch RENDEZVOUS_SERVERS
if grep -q 'YOUR_SERVER_IP' "$CONFIG_FILE"; then
    sed -i "s|YOUR_SERVER_IP|$SERVER_IP|g" "$CONFIG_FILE"
    echo "[OK] Patched RENDEZVOUS_SERVERS with $SERVER_IP"
elif grep -q "RENDEZVOUS_SERVERS.*\[" "$CONFIG_FILE"; then
    sed -i "s|pub const RENDEZVOUS_SERVERS: &\[&str\] = &\[\"[^\"]*\"\];|pub const RENDEZVOUS_SERVERS: \&[\&str] = \&[\"$SERVER_IP\"];|" "$CONFIG_FILE"
    echo "[OK] Updated RENDEZVOUS_SERVERS to $SERVER_IP"
else
    echo "[WARN] Could not find RENDEZVOUS_SERVERS in $CONFIG_FILE - please update manually"
fi

# Patch RS_PUB_KEY
if grep -q 'YOUR_PUBLIC_KEY' "$CONFIG_FILE"; then
    sed -i "s|YOUR_PUBLIC_KEY|$PUBLIC_KEY|g" "$CONFIG_FILE"
    echo "[OK] Patched RS_PUB_KEY with your public key"
elif grep -q 'RS_PUB_KEY' "$CONFIG_FILE"; then
    sed -i "s|pub const RS_PUB_KEY: &str = \"[^\"]*\";|pub const RS_PUB_KEY: \&str = \"$PUBLIC_KEY\";|" "$CONFIG_FILE"
    echo "[OK] Updated RS_PUB_KEY"
else
    echo "[WARN] Could not find RS_PUB_KEY in $CONFIG_FILE - please update manually"
fi

echo ""
echo "=== Configuration Complete ==="
echo ""
echo "Verify the changes:"
grep "RENDEZVOUS_SERVERS" "$CONFIG_FILE" | head -1
grep "RS_PUB_KEY" "$CONFIG_FILE" | head -1
echo ""
echo "Next steps:"
echo "  1. Commit and push your changes"
echo "  2. GitHub Actions will automatically build all platforms"
echo "  3. Download artifacts from Actions tab"

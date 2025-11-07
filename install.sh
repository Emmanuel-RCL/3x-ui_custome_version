#!/bin/bash
set -e

# ============================================
# 🔧 Dynamic X-UI Installer (by version input)
# Source: https://github.com/MHSanaei/3x-ui
# Compatible: Linux AMD64
# ============================================

echo "============================================"
echo "     🚀 X-UI Auto Installer (GitHub Source)"
echo "============================================"
echo
read -p "🔢 Enter desired version (e.g., 2.6.3): " VERSION
echo

# Validate input format (x.y.z)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Invalid version format! Use format: x.y.z (e.g., 2.6.3)"
    exit 1
fi

# Download URL
DOWNLOAD_URL="https://github.com/MHSanaei/3x-ui/releases/download/v$VERSION/x-ui-linux-amd64.tar.gz"

echo "[*] Downloading x-ui version $VERSION ..."
wget -O x-ui-linux-amd64.tar.gz "$DOWNLOAD_URL" || { echo "❌ Download failed! Check version number."; exit 1; }

echo "[*] Extracting archive..."
tar zxvf x-ui-linux-amd64.tar.gz

echo "[*] Setting executable permissions..."
chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh

echo "[*] Copying and moving files..."
if [ -d "/usr/local/x-ui" ]; then
    echo "[*] Updating existing /usr/local/x-ui directory..."
    cp -rf x-ui/* /usr/local/x-ui/
else
    echo "[*] Moving x-ui folder to /usr/local/"
    mv x-ui/ /usr/local/
fi

cp /usr/local/x-ui/x-ui.sh /usr/bin/x-ui
cp -f /usr/local/x-ui/x-ui.service /etc/systemd/system/

echo "[*] Reloading systemd and starting x-ui service..."
systemctl daemon-reload
systemctl enable x-ui
systemctl restart x-ui

# ----------------------------
# Configure to use HTTP and IP access only
# ----------------------------
echo "[*] Configuring x-ui to use HTTP and IP access only..."

CONFIG_PATH="/usr/local/x-ui/config.json"
if [ ! -f "$CONFIG_PATH" ]; then
    cat <<EOF > "$CONFIG_PATH"
{
  "webPort": 2053,
  "webCertFile": "",
  "webKeyFile": "",
  "webDomain": "",
  "webListen": "0.0.0.0",
  "webBasePath": "",
  "webHttps": false
}
EOF
    echo "[*] Default HTTP configuration created at $CONFIG_PATH"
fi

systemctl restart x-ui

IP=$(hostname -I | awk '{print $1}')

echo
echo "======================================================"
echo "✅ X-UI v$VERSION installed and running successfully!"
echo "🌐 Access panel via: http://$IP:2053"
echo "🧩 Default username: admin"
echo "🔑 Default password: admin"
echo "⚙️  To manage panel, run: x-ui"
echo "======================================================"

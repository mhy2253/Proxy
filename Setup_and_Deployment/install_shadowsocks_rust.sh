#!/usr/bin/env bash
set -euo pipefail

VERSION="v1.24.0"
ARCHIVE="shadowsocks-${VERSION}.aarch64-unknown-linux-gnu.tar.xz"
DOWNLOAD_URL="https://github.com/shadowsocks/shadowsocks-rust/releases/download/${VERSION}/${ARCHIVE}"

INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/shadowsocks-rust"
CONFIG_FILE="${CONFIG_DIR}/config.json"
SERVICE_FILE="/etc/systemd/system/ssserver.service"

METHOD="chacha20-ietf-poly1305"
SERVER_PORT="8388"
SERVER_ADDR="::"
TIMEOUT="300"
MODE="tcp_and_udp"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

echo "==> Downloading ${ARCHIVE}"
cd "${WORKDIR}"
wget -O "${ARCHIVE}" "${DOWNLOAD_URL}"

echo "==> Extracting package"
tar -xf "${ARCHIVE}"

echo "==> Installing binaries"
sudo install -m 755 ssserver "${INSTALL_DIR}/ssserver"
sudo install -m 755 ssservice "${INSTALL_DIR}/ssservice"

echo "==> Generating password"
PASSWORD="$("${INSTALL_DIR}/ssservice" genkey -m "${METHOD}")"

echo "==> Creating config directory"
sudo mkdir -p "${CONFIG_DIR}"

echo "==> Writing config file: ${CONFIG_FILE}"
sudo tee "${CONFIG_FILE}" > /dev/null <<EOF
{
  "server": "${SERVER_ADDR}",
  "server_port": ${SERVER_PORT},
  "password": "${PASSWORD}",
  "method": "${METHOD}",
  "timeout": ${TIMEOUT},
  "mode": "${MODE}"
}
EOF

echo "==> Writing systemd service: ${SERVICE_FILE}"
sudo tee "${SERVICE_FILE}" > /dev/null <<'EOF'
[Unit]
Description=shadowsocks-rust Server Service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/ssserver -c /etc/shadowsocks-rust/config.json
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

echo "==> Reloading systemd"
sudo systemctl daemon-reload

echo "==> Enabling service"
sudo systemctl enable ssserver

echo "==> Starting service"
sudo systemctl restart ssserver

echo
echo "Deployment completed."
echo "Config file: ${CONFIG_FILE}"
echo "Server port: ${SERVER_PORT}"
echo "Method: ${METHOD}"
echo "Generated password: ${PASSWORD}"
echo
echo "Service status:"
systemctl status ssserver --no-pager

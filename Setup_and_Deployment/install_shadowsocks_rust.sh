```bash
#!/usr/bin/env bash
set -euo pipefail

REPO="shadowsocks/shadowsocks-rust"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/shadowsocks-rust"
CONFIG_FILE="${CONFIG_DIR}/config.json"
SERVICE_FILE="/etc/systemd/system/ssserver.service"

METHOD="chacha20-ietf-poly1305"
SERVER_PORT="8388"
SERVER_ADDR="::"
TIMEOUT="300"
MODE="tcp_and_udp"

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: $1 is required but not installed."
    exit 1
  }
}

echo "==> Checking dependencies"
for cmd in uname tar sudo systemctl mktemp find grep sed; do
  require_cmd "$cmd"
done

if command -v curl >/dev/null 2>&1; then
  DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
  DOWNLOADER="wget"
else
  echo "Error: curl or wget is required but neither is installed."
  exit 1
fi

if [[ $EUID -ne 0 ]] && ! sudo -n true 2>/dev/null; then
  echo "Error: This script requires root privileges or a sudo-enabled user."
  echo "Please run as root, or use a user that can run sudo."
  exit 1
fi

echo "==> Detecting architecture"
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64)
    TARGET="x86_64-unknown-linux-gnu"
    ;;
  aarch64|arm64)
    TARGET="aarch64-unknown-linux-gnu"
    ;;
  *)
    echo "Error: Unsupported architecture: ${ARCH}"
    exit 1
    ;;
esac

echo "==> Fetching latest release version"
if [[ "${DOWNLOADER}" == "curl" ]]; then
  LATEST_URL="$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest")"
else
  LATEST_URL="$(wget -S --max-redirect=20 -O /dev/null "https://github.com/${REPO}/releases/latest" 2>&1 | awk '/^  Location: /{print $2}' | tail -n1 | tr -d '\r')"
fi

VERSION="${LATEST_URL##*/}"

if [[ -z "${VERSION}" || "${VERSION}" == "latest" ]]; then
  echo "Error: Failed to determine latest version."
  exit 1
fi

ARCHIVE="shadowsocks-${VERSION}.${TARGET}.tar.xz"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${VERSION}/${ARCHIVE}"

WORKDIR="$(mktemp -d)"
trap 'rm -rf "${WORKDIR}"' EXIT

echo "==> Version: ${VERSION}"
echo "==> Architecture: ${ARCH} -> ${TARGET}"
echo "==> Download URL: ${DOWNLOAD_URL}"

cd "${WORKDIR}"

echo "==> Downloading package"
if [[ "${DOWNLOADER}" == "curl" ]]; then
  curl -fL "${DOWNLOAD_URL}" -o "${ARCHIVE}"
else
  wget -O "${ARCHIVE}" "${DOWNLOAD_URL}"
fi

echo "==> Extracting package"
tar -xf "${ARCHIVE}"

SSSERVER_BIN="$(find "${WORKDIR}" -type f -name ssserver | head -n 1)"
SSSERVICE_BIN="$(find "${WORKDIR}" -type f -name ssservice | head -n 1)"

if [[ -z "${SSSERVER_BIN}" ]]; then
  echo "Error: ssserver binary not found after extraction."
  exit 1
fi

if [[ -z "${SSSERVICE_BIN}" ]]; then
  echo "Error: ssservice binary not found after extraction."
  exit 1
fi

echo "==> Installing binaries"
sudo install -m 755 "${SSSERVER_BIN}" "${INSTALL_DIR}/ssserver"
sudo install -m 755 "${SSSERVICE_BIN}" "${INSTALL_DIR}/ssservice"

echo "==> Generating password"
PASSWORD="$("${INSTALL_DIR}/ssservice" genkey -m "${METHOD}")"

echo "==> Creating config directory"
sudo mkdir -p "${CONFIG_DIR}"

echo "==> Writing config file"
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

echo "==> Writing systemd service"
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
echo "Version: ${VERSION}"
echo "Architecture: ${TARGET}"
echo "Config file: ${CONFIG_FILE}"
echo "Server port: ${SERVER_PORT}"
echo "Method: ${METHOD}"
echo "Generated password: ${PASSWORD}"
echo
echo "Service status:"
systemctl status ssserver --no-pager
```

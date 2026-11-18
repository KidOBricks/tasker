#!/usr/bin/env bash
set -euo pipefail

# One-command bootstrap script for Ubuntu (ARM64 / x86_64) on Oracle Cloud Infrastructure.
# Usage:
#   sudo bash deploy/oci-setup.sh [--ip <PUBLIC_IP>] [--domain <CUSTOM_DOMAIN>]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PUBLIC_IP=""
CUSTOM_DOMAIN=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ip)
      PUBLIC_IP="$2"
      shift 2
      ;;
    --domain)
      CUSTOM_DOMAIN="$2"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1"
      exit 1
      ;;
  esac
done

if [[ "${EUID}" -ne 0 ]]; then
  echo "Please run with sudo: sudo bash $0"
  exit 1
fi

if [[ -z "${CUSTOM_DOMAIN}" ]]; then
  if [[ -z "${PUBLIC_IP}" ]]; then
    PUBLIC_IP="$(curl -fsSL https://api.ipify.org || curl -fsSL https://ifconfig.me)"
  fi
  DASHED_IP="${PUBLIC_IP//./-}"
  TASKER_DOMAIN="${DASHED_IP}.sslip.io"
else
  TASKER_DOMAIN="${CUSTOM_DOMAIN}"
fi

TASKER_PUBLIC_URL="https://${TASKER_DOMAIN}"
echo "==> Configuring Tasker for domain: ${TASKER_PUBLIC_URL}"

# 1. Install base dependencies & Caddy
apt-get update -y
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl openssl ufw

if ! command -v caddy >/dev/null 2>&1; then
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
  apt-get update -y
  apt-get install -y caddy
fi

# 2. Create service user and directory layout
id -u tasker >/dev/null 2>&1 || useradd --system --home /opt/tasker --shell /usr/sbin/nologin tasker
mkdir -p /opt/tasker/pb_data /opt/tasker/web

# 3. Install or build tasker-server binary
if [[ -f "${REPO_ROOT}/backend/tasker-server" ]]; then
  cp "${REPO_ROOT}/backend/tasker-server" /opt/tasker/tasker-server
elif command -v go >/dev/null 2>&1; then
  echo "==> Building Go PocketBase binary..."
  (cd "${REPO_ROOT}/backend" && CGO_ENABLED=0 go build -o /opt/tasker/tasker-server .)
else
  echo "ERROR: Neither prebuilt backend/tasker-server nor Go toolchain found."
  echo "Install Go or copy the compiled tasker-server binary to ${REPO_ROOT}/backend/tasker-server."
  exit 1
fi
chmod +x /opt/tasker/tasker-server

# 4. Copy Flutter Web build if available
if [[ -d "${REPO_ROOT}/build/web" ]]; then
  rsync -a --delete "${REPO_ROOT}/build/web/" /opt/tasker/web/
elif [[ ! -f /opt/tasker/web/index.html ]]; then
  cat > /opt/tasker/web/index.html <<'HTML'
<!doctype html>
<html><body style="font-family:sans-serif;padding:2rem;">
  <h1>Tasker Backend Online</h1>
  <p>PocketBase is running. Deploy Flutter Web build to <code>/opt/tasker/web</code> or open <a href="/_/">Admin UI (/_/)</a>.</p>
</body></html>
HTML
fi

# 5. Create /opt/tasker/.env if missing
if [[ ! -f /opt/tasker/.env ]]; then
  cp "${SCRIPT_DIR}/.env.example" /opt/tasker/.env
  ENC_KEY="$(openssl rand -hex 32)"
  sed -i "s|^TASKER_DOMAIN=.*|TASKER_DOMAIN=${TASKER_DOMAIN}|" /opt/tasker/.env
  sed -i "s|^TASKER_PUBLIC_URL=.*|TASKER_PUBLIC_URL=${TASKER_PUBLIC_URL}|" /opt/tasker/.env
  sed -i "s|^TOKEN_ENCRYPTION_KEY=.*|TOKEN_ENCRYPTION_KEY=${ENC_KEY}|" /opt/tasker/.env
  chmod 600 /opt/tasker/.env
fi

chown -R tasker:tasker /opt/tasker

# 6. Configure Caddy & systemd
sed "s|{\\\$TASKER_DOMAIN}|${TASKER_DOMAIN}|g" "${SCRIPT_DIR}/Caddyfile.template" > /etc/caddy/Caddyfile
cp "${SCRIPT_DIR}/tasker.service" /etc/systemd/system/tasker.service

systemctl daemon-reload
systemctl enable --now tasker.service
systemctl reload caddy || systemctl enable --now caddy

# 7. Open HTTP/HTTPS firewall ports (note: also allow 80 & 443 in OCI Security List!)
ufw allow 22/tcp >/dev/null 2>&1 || true
ufw allow 80/tcp >/dev/null 2>&1 || true
ufw allow 443/tcp >/dev/null 2>&1 || true

echo ""
echo "=========================================================="
echo " Tasker Server Installed!"
echo " App URL:          ${TASKER_PUBLIC_URL}"
echo " PocketBase Admin: ${TASKER_PUBLIC_URL}/_/"
echo ""
echo " Next steps:"
echo " 1. Ensure OCI VCN Security List allows TCP 80 and 443."
echo " 2. Add OAuth credentials & LLM key in /opt/tasker/.env, then:"
echo "      sudo systemctl restart tasker"
echo " 3. Register these OAuth Redirect URIs:"
echo "    - Google:    ${TASKER_PUBLIC_URL}/api/integrations/google/callback"
echo "                 ${TASKER_PUBLIC_URL}/api/oauth2-redirect"
echo "    - Microsoft: ${TASKER_PUBLIC_URL}/api/integrations/microsoft/callback"
echo "                 ${TASKER_PUBLIC_URL}/api/oauth2-redirect"
echo "=========================================================="

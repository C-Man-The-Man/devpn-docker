#!/bin/bash

set -e

CONFIG_DIR="/opt/devpn"
CONFIG_FILE="${CONFIG_DIR}/config.json"
ENV_FILE="${CONFIG_DIR}/.env"
AGENT_FILE="${CONFIG_DIR}/dvpn-provider.py"

mkdir -p "${CONFIG_DIR}"

echo "[INFO] Starting DeVPN container"

if [ -z "${DEVPN_TOKEN}" ]; then
    echo "[ERROR] DEVPN_TOKEN environment variable not set"
    echo "[ERROR] Start the container with:"
    echo "         -e DEVPN_TOKEN=YOUR_TOKEN"
    exit 1
fi

if [ ! -f "${ENV_FILE}" ]; then
    cat > "${ENV_FILE}" <<EOF
DIY_TOKEN=${DEVPN_TOKEN}
AGENT_TOKEN=
PROVIDER_ID=
EOF
fi

FIRST_RUN=false

if [ ! -f "${CONFIG_FILE}" ] || [ ! -f "${AGENT_FILE}" ]; then
    FIRST_RUN=true
fi

if [ "${FIRST_RUN}" = "true" ]; then

    echo "[INFO] First run detected"
    echo "[INFO] Running official installer"

    curl -sSL https://api.devpn.org/static/install-provider.sh | \
    bash -s -- --token "${DEVPN_TOKEN}"

    if [ -f "${CONFIG_FILE}" ]; then

        AGENT_TOKEN=$(jq -r '.agent_token // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        PROVIDER_ID=$(jq -r '.provider_id // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")

        if [ -n "${AGENT_TOKEN}" ] && [ "${AGENT_TOKEN}" != "null" ]; then
            sed -i "s|^AGENT_TOKEN=.*|AGENT_TOKEN=${AGENT_TOKEN}|" "${ENV_FILE}"
        fi

        if [ -n "${PROVIDER_ID}" ] && [ "${PROVIDER_ID}" != "null" ]; then
            sed -i "s|^PROVIDER_ID=.*|PROVIDER_ID=${PROVIDER_ID}|" "${ENV_FILE}"
        fi

    fi

    echo "[INFO] Installer completed"

else

    echo "[INFO] Existing configuration found"

fi

if [ -f /opt/devpn/wg0.conf ]; then
    wg-quick up /opt/devpn/wg0.conf || true
fi

if [ -f /opt/devpn/wg-relay.conf ]; then
    wg-quick up /opt/devpn/wg-relay.conf || true
fi

exec python3 /opt/devpn/dvpn-provider.py

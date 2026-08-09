#!/usr/bin/env bash

# EC2 deployment script.

set -Eeuo pipefail

required_variables=(
  RELEASE_SHA
  SOURCE_DIR
  AWS_REGION
  RDS_SECRET_ARN
  DB_HOST
  DB_PORT
  DB_NAME
  APP_PORT
  EXPECTED_PORT
)

for variable_name in "${required_variables[@]}"; do
  if [[ -z "${!variable_name:-}" ]]; then
    echo "Required variable is missing: ${variable_name}"
    exit 1
  fi
done

APP_NAME="users-posts-api"
APP_USER="users-posts-api"
APP_GROUP="users-posts-api"

APP_ROOT="/opt/${APP_NAME}"
RELEASES_DIR="${APP_ROOT}/releases"
RELEASE_DIR="${RELEASES_DIR}/${RELEASE_SHA}"
CURRENT_LINK="${APP_ROOT}/current"
VENV_DIR="${APP_ROOT}/venv"

SERVICE_NAME="${APP_NAME}.service"
SERVICE_UNIT_PATH="/etc/systemd/system/${SERVICE_NAME}"
PLACEHOLDER_SERVICE="meeps-backend.service"

previous_release=""
switched_release="false"
placeholder_was_active="false"

if systemctl is-active --quiet "${PLACEHOLDER_SERVICE}"; then
  placeholder_was_active="true"
fi

if [[ -L "${CURRENT_LINK}" ]]; then
  previous_release="$(readlink -f "${CURRENT_LINK}")"
fi

rollback() {
  exit_code=$?

  trap - ERR
  set +e

  echo "Deployment failed. Starting rollback."

  if [[ "${switched_release}" == "true" ]] &&
     [[ -n "${previous_release}" ]] &&
     [[ -d "${previous_release}" ]]; then

    echo "Restoring previous release: ${previous_release}"

    ln -sfn "${previous_release}" "${CURRENT_LINK}"

    systemctl daemon-reload
    systemctl restart "${SERVICE_NAME}"

    for attempt in {1..20}; do
      if curl -fsS \
        "http://127.0.0.1:${EXPECTED_PORT}/health" \
        >/dev/null; then

        echo "Rollback health check passed."
        break
      fi

      sleep 3
    done

  elif [[ "${placeholder_was_active}" == "true" ]]; then
    echo "No previous FastAPI release. Restoring placeholder service."

    if [[ -f "${SERVICE_UNIT_PATH}" ]]; then
      systemctl disable --now "${SERVICE_NAME}" || true
    fi

    systemctl enable --now "${PLACEHOLDER_SERVICE}"
  fi

  if [[ -f "${SERVICE_UNIT_PATH}" ]]; then
    systemctl status "${SERVICE_NAME}" \
      --no-pager \
      --full || true

    journalctl \
      -u "${SERVICE_NAME}" \
      -n 100 \
      --no-pager || true
  fi

  exit "${exit_code}"
}

trap rollback ERR

echo "Installing required operating-system packages."

dnf install -y \
  python3.12 \
  python3.12-pip

command -v aws
command -v curl
command -v python3.12

getent group "${APP_GROUP}" >/dev/null 2>&1 ||
  groupadd --system "${APP_GROUP}"

id -u "${APP_USER}" >/dev/null 2>&1 ||
  useradd \
    --system \
    --gid "${APP_GROUP}" \
    --home-dir "${APP_ROOT}" \
    --shell /sbin/nologin \
    "${APP_USER}"

install -d \
  -o "${APP_USER}" \
  -g "${APP_GROUP}" \
  -m 0755 \
  "${APP_ROOT}" \
  "${RELEASES_DIR}"

rm -rf "${RELEASE_DIR}"

install -d \
  -o "${APP_USER}" \
  -g "${APP_GROUP}" \
  -m 0755 \
  "${RELEASE_DIR}"

cp -a "${SOURCE_DIR}/." "${RELEASE_DIR}/"

chmod 0755 \
  "${RELEASE_DIR}/scripts/start-api.sh" \
  "${RELEASE_DIR}/scripts/run-migrations.sh" \
  "${RELEASE_DIR}/scripts/deploy-ec2.sh"

echo "Retrieving the RDS-managed secret."

SECRET_JSON="$(
  aws secretsmanager get-secret-value \
    --secret-id "${RDS_SECRET_ARN}" \
    --region "${AWS_REGION}" \
    --query SecretString \
    --output text
)"

export SECRET_JSON
export DB_HOST
export DB_PORT
export DB_NAME

DATABASE_URL="$(
  python3.12 <<'PYTHON'
import json
import os
from urllib.parse import quote

secret = json.loads(os.environ["SECRET_JSON"])

username = quote(secret["username"], safe="")
password = quote(secret["password"], safe="")
host = os.environ["DB_HOST"]
port = os.environ["DB_PORT"]
database = os.environ["DB_NAME"]

print(
    f"postgresql://{username}:{password}"
    f"@{host}:{port}/{database}"
)
PYTHON
)"

unset SECRET_JSON

install \
  -o "${APP_USER}" \
  -g "${APP_GROUP}" \
  -m 0600 \
  /dev/null \
  "${RELEASE_DIR}/.env"

cat > "${RELEASE_DIR}/.env" <<EOF
DATABASE_URL=${DATABASE_URL}
HOST=0.0.0.0
PORT=${APP_PORT}
EOF

chown -R "${APP_USER}:${APP_GROUP}" "${RELEASE_DIR}"
chmod 0600 "${RELEASE_DIR}/.env"

if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
  python3.12 -m venv "${VENV_DIR}"
fi

"${VENV_DIR}/bin/python" \
  -m pip install \
  --upgrade pip

"${VENV_DIR}/bin/python" \
  -m pip install \
  --no-cache-dir \
  -r "${RELEASE_DIR}/requirements.txt"

chown -R "root:${APP_GROUP}" "${VENV_DIR}"
chmod -R u=rwX,g=rX,o= "${VENV_DIR}"

echo "Running Alembic migrations."

pushd "${RELEASE_DIR}" >/dev/null

DATABASE_URL="${DATABASE_URL}" \
  "${VENV_DIR}/bin/alembic" upgrade head

popd >/dev/null

cat > "${SERVICE_UNIT_PATH}" <<'SERVICE'
[Unit]
Description=Users Posts FastAPI service
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=users-posts-api
Group=users-posts-api

WorkingDirectory=/opt/users-posts-api/current
EnvironmentFile=/opt/users-posts-api/current/.env
Environment=PYTHONUNBUFFERED=1
Environment=PATH=/opt/users-posts-api/venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

ExecStart=/opt/users-posts-api/current/scripts/start-api.sh

Restart=always
RestartSec=5
TimeoutStartSec=30

NoNewPrivileges=true
PrivateTmp=true

[Install]
WantedBy=multi-user.target
SERVICE

chmod 0644 "${SERVICE_UNIT_PATH}"

echo "Stopping the temporary placeholder backend."

systemctl disable --now "${PLACEHOLDER_SERVICE}" || true

ln -sfn "${RELEASE_DIR}" "${CURRENT_LINK}"
switched_release="true"

systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl restart "${SERVICE_NAME}"

echo "Waiting for the local application health check."

application_healthy="false"

for attempt in {1..30}; do
  if curl -fsS \
    "http://127.0.0.1:${EXPECTED_PORT}/health" \
    >/dev/null; then

    application_healthy="true"
    break
  fi

  sleep 5
done

if [[ "${application_healthy}" != "true" ]]; then
  echo "Application failed the expected-port health check."

  systemctl status "${SERVICE_NAME}" \
    --no-pager \
    --full || true

  journalctl \
    -u "${SERVICE_NAME}" \
    -n 100 \
    --no-pager || true

  false
fi

echo "Testing the database-backed users endpoint."

curl -fsS \
  "http://127.0.0.1:${EXPECTED_PORT}/users/" \
  >/dev/null

trap - ERR

echo "Deployment succeeded."
echo "Release: ${RELEASE_SHA}"
echo "Current: $(readlink -f "${CURRENT_LINK}")"

systemctl status "${SERVICE_NAME}" \
  --no-pager \
  --full

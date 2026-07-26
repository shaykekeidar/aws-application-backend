#!/bin/bash

set -e

HEALTH_URL="http://localhost:12008/api/status"
MAX_ATTEMPTS=12
SLEEP_SECONDS=5

echo "Validating backend at ${HEALTH_URL}"

for attempt in $(seq 1 "${MAX_ATTEMPTS}"); do
    echo "Validation attempt ${attempt}/${MAX_ATTEMPTS}"

    if curl --fail --silent "${HEALTH_URL}" | grep -q '"status":"UP"'; then
        echo "Backend validation succeeded"
        exit 0
    fi

    sleep "${SLEEP_SECONDS}"
done

echo "Backend validation failed"

systemctl status cicd-backend.service --no-pager || true
journalctl -u cicd-backend.service --no-pager -n 50 || true

exit 1
#!/bin/bash

set -e

echo "Stopping existing backend service"

if systemctl list-unit-files | grep -q "^cicd-backend.service"; then
    systemctl stop cicd-backend.service || true
fi

exit 0
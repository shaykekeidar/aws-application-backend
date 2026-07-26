#!/bin/bash

set -e

APPLICATION_DIRECTORY="/opt/aws-cicd-backend"
SERVICE_FILE="/etc/systemd/system/cicd-backend.service"

echo "Installing backend application"

if ! command -v node >/dev/null 2>&1; then
    echo "Node.js is not installed"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "npm is not installed"
    exit 1
fi

cd "${APPLICATION_DIRECTORY}"

echo "Installing production dependencies"
npm ci --omit=dev

echo "Installing systemd service"
cp "${APPLICATION_DIRECTORY}/cicd-backend.service" "${SERVICE_FILE}"

chown -R ec2-user:ec2-user "${APPLICATION_DIRECTORY}"

systemctl daemon-reload
systemctl enable cicd-backend.service

echo "Backend installation completed"
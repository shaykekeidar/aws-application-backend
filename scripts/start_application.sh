#!/bin/bash

set -e

echo "Starting backend service"

systemctl restart cicd-backend.service
systemctl status cicd-backend.service --no-pager

echo "Backend service started"
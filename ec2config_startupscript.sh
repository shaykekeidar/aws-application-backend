#!/bin/bash

set -euxo pipefail

REGION="eu-west-1"

# Record output for troubleshooting.
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting EC2 bootstrap"

# Update packages.
dnf update -y

# Do not install full curl because AL2023 already includes curl-minimal.
dnf install -y \
  git \
  wget \
  ruby \
  nodejs22 \
  nodejs22-npm

echo "Installed versions:"
git --version
node --version
npm --version
ruby --version
wget --version

# Create the application directory.
mkdir -p /opt/aws-cicd-backend
chown -R ec2-user:ec2-user /opt/aws-cicd-backend

# Install the CodeDeploy agent.
cd /tmp

wget \
  "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install" \
  -O codedeploy-install

chmod +x codedeploy-install
./codedeploy-install auto

systemctl enable codedeploy-agent
systemctl restart codedeploy-agent

echo "CodeDeploy agent status:"
systemctl status codedeploy-agent --no-pager

echo "EC2 bootstrap completed"
#!/bin/bash
# Script to install kubectl on an Ubuntu instance

set -e  # Exit on error

# Update system and install dependencies
sudo apt-get update -y
sudo apt-get install -y curl

# Download the latest stable version of kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"

# Install kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verify installation
echo "kubectl version:"
kubectl version --client

# Clean up
rm kubectl

echo "kubectl ${KUBECTL_VERSION} installed successfully."


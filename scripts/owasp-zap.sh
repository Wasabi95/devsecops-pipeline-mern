#!/bin/bash
# Script to install and run OWASP ZAP in headless mode on an Ubuntu EC2 instance

echo "Updating packages..."
sudo apt-get update -y

echo "Installing Java (required for ZAP)..."
sudo apt-get install -y openjdk-17-jre wget unzip

# Define ZAP version
ZAP_VERSION="2.15.0"

# Download ZAP
echo "Downloading OWASP ZAP..."
cd /opt
sudo wget https://github.com/zaproxy/zaproxy/releases/download/v${ZAP_VERSION}/ZAP_${ZAP_VERSION}_Linux.tar.gz

echo "Extracting ZAP..."
sudo tar -xvzf ZAP_${ZAP_VERSION}_Linux.tar.gz
sudo mv ZAP_${ZAP_VERSION} zap
sudo rm ZAP_${ZAP_VERSION}_Linux.tar.gz

# Create a symlink for easier use
sudo ln -s /opt/zap/zap.sh /usr/local/bin/zap

# Run a sample scan in headless mode (optional)
# You can customize the target as needed
TARGET_URL="http://localhost:3000"

echo "Running OWASP ZAP in headless mode for target: $TARGET_URL"
sudo /opt/zap/zap.sh -cmd -quickurl "$TARGET_URL" -quickout /opt/zap/zap-report.html

echo "ZAP scan completed. Report saved to /opt/zap/zap-report.html"

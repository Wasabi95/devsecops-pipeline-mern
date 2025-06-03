#!/bin/bash
# Script to install Grafana on a Linux instance

set -e  # Exit immediately if a command exits with a non-zero status

# Update package list and install dependencies
sudo apt-get update -y
sudo apt-get install -y apt-transport-https software-properties-common wget gpg

# Create a directory for Grafana's GPG key
sudo mkdir -p /etc/apt/keyrings/

# Add Grafana's GPG key
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null

# Add Grafana's repository to the sources list
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list

# Update package lists again after adding repo
sudo apt-get update -y

# Install the latest OSS release of Grafana
sudo apt-get install -y grafana

# Start and enable Grafana service
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "Grafana installation complete. Access it at http://<your-ec2-ip>:3000"

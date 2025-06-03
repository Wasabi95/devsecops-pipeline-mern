#!/bin/bash
# Script to install and run SonarQube using Docker

# Update the package list
sudo apt update -y

# Install Docker if it's not installed
if ! command -v docker &> /dev/null; then
  echo "Installing Docker..."
  sudo apt install -y docker.io
fi

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the Docker group
sudo usermod -aG docker $USER

# Pull the latest SonarQube community image
echo "Pulling SonarQube image..."
sudo docker pull sonarqube:lts-community

# Create SonarQube container
echo "Running SonarQube container..."
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:lts-community

# Wait a few seconds for container to start
sleep 10

# Print status
echo "SonarQube container started. Access it at: http://<your-ec2-ip>:9000"

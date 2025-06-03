#!/bin/bash
# Jenkins installation script for Ubuntu

set -e  # Exit immediately if any command fails

# Update system
sudo apt-get update -y

# Install dependencies (Java 17 for Jenkins)
sudo apt-get install -y fontconfig openjdk-17-jre wget gnupg

# Add Jenkins GPG key and repository
sudo mkdir -p /usr/share/keyrings
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists and install Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# Enable and start Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins installation complete. Access it at http://<your-ec2-ip>:8080"

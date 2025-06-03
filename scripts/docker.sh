#!/bin/bash
# Script to install Docker on an EC2 instance and configure permissions

# Update the package list
sudo apt-get update -y

# Install Docker
sudo apt-get install docker.io -y

# Enable Docker to start on boot
sudo systemctl enable docker

# Add the 'ubuntu' and 'jenkins' users to the 'docker' group
sudo usermod -aG docker ubuntu 
sudo usermod -aG docker jenkins 

# Restart Docker service to apply group changes
sudo systemctl restart docker

# Print Docker version to verify installation
docker --version

# Note: Logout or reboot may be required for group changes to take effect

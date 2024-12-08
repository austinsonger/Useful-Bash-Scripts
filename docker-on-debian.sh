#!/bin/bash

# Function to install Docker for Debian-based distributions
install_docker_debian() {
    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

    # Set up the stable repository
    echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# Function to install Docker for Ubuntu-based distributions
install_docker_ubuntu() {
    # Add Docker’s official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

    # Set up the stable repository
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

# Detect the Linux Distribution
. /etc/os-release

# Update the apt package index
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

# Check if the distribution is Ubuntu or Debian and call the respective function
case "$ID" in
    ubuntu)
        install_docker_ubuntu
        ;;
    debian)
        install_docker_debian
        ;;
    *)
        echo "Your distribution is not supported by this script."
        exit 1
        ;;
esac

# Update the apt package index again
sudo apt-get update

# Install the latest version of Docker CE and containerd
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Verify that Docker CE is installed correctly by running the hello-world image
sudo docker run hello-world

# Install Docker Compose
# Check the latest release of Docker Compose on https://github.com/docker/compose/releases
# Replace the version number in the command below if necessary
DOCKER_COMPOSE_VERSION="1.29.2"
sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Apply executable permissions to the Docker Compose binary
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker-compose --version

# Adding current user to the Docker group to avoid using 'sudo' with Docker commands
sudo usermod -aG docker $USER

# Note: You might need to log out and log back in for this to take effect

echo "Docker and Docker Compose installation script has completed."

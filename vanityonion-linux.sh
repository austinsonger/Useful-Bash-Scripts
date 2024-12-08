#!/bin/bash

# Install dependencies
echo "Installing dependencies..."
sudo apt update
sudo apt install -y gcc libc6-dev libsodium-dev make autoconf

# Clone the Git repository
REPO_URL="https://github.com/cathugger/mkp224o.git"
CLONE_DIR="$HOME/mkp224o"
if [ ! -d "$CLONE_DIR" ]; then
    echo "Cloning the Git repository..."
    git clone $REPO_URL $CLONE_DIR
else
    echo "Repository already cloned."
fi

# Change into the mkp224o directory
cd $CLONE_DIR

# Build mkp224o
echo "Building mkp224o..."
./autogen.sh
./configure
make

# Generate the vanity address
echo "Generating the vanity address..."
DESIRED_KEY="oniondomain"  
THREADS="number-of-threads"  # Replace this with the number of threads
OUTPUT_DIR="$HOME/new_onion"
./mkp224o $DESIRED_KEY -v -n 1 -d $OUTPUT_DIR -t $THREADS

# Copy the address to the Tor hidden service directory
HIDDEN_SERVICE_DIR="/var/lib/tor/hidden_service"
ADDRESS_DIR="$OUTPUT_DIR/$DESIRED_KEY"
if [ -d "$ADDRESS_DIR" ]; then
    echo "Copying the address to the Tor hidden service directory..."
    sudo cp -r $ADDRESS_DIR $HIDDEN_SERVICE_DIR
    sudo cp $ADDRESS_DIR/* $HIDDEN_SERVICE_DIR
    sudo rm -r $ADDRESS_DIR
else
    echo "Address directory not found."
fi

# Restart Tor
echo "Restarting Tor..."
sudo systemctl restart tor

# Check if everything worked correctly
echo "Checking the .onion address..."
sudo cat $HIDDEN_SERVICE_DIR/hostname

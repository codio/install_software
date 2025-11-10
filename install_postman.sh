#!/bin/bash

# Download the latest Postman tarball
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz

# Extract to /opt directory
sudo tar -xzf postman.tar.gz -C /opt

# Create a symbolic link to make Postman accessible globally
sudo ln -s /opt/Postman/Postman /usr/local/bin/postman

# Clean up the tarball
rm postman.tar.gz

echo "Postman installed successfully!"


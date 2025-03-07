#!/bin/sh

# Install Node.js v18
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node.js and npm installation
node -v
npm -v

# Install Python dependencies
pip install -r requirements.txt
pip install --upgrade pip
#!/bin/sh

# Install Grunt CLI tool
npm install -g grunt-cli

# Switch to vagrant user
sudo -i -u vagrant

# Change to public folder
cd /vagrant

# Install grunt dependencies
npm install

# Install the project (disabled due to slow GIT)
# grunt project:install

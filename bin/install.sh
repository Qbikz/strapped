#!/bin/bash

if [[ $EUID -ne 0 ]]; then
    echo "Please run this script with sudo" 2>&1
    exit 1
else
    # Install base packages
    apt-get install -y \
        curl git git-flow nodejs npm mysql-client \
        nfs-server python-software-properties virtualbox \
        php5-cli php5-mcrypt php5-mhash php5-gd php5-xmlrpc php5-redis \
        php5-mysqlnd php5-xsl php5-memcached php5-json php5-curl \
        libsnappy1

    # Install Vagrant
    curl -L -o /tmp/vagrant.deb https://dl.bintray.com/mitchellh/vagrant/vagrant_1.6.1_x86_64.deb
    dpkg -i /tmp/vagrant.deb

    # Install Grunt
    npm install -g grunt-cli
fi

#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPTPATH=`dirname $SCRIPT`
BASEPATH=`dirname $SCRIPTPATH`

# Fetch dependencies
cd $SCRIPTPATH

curl -L -o n98-magerun.phar https://raw.github.com/netz98/n98-magerun/master/n98-magerun.phar
curl -L -o composer.phar https://getcomposer.org/composer.phar

chmod +x composer.phar
chmod +x n98-magerun.phar

# Create project
cd $BASEPATH

# Install nodejs modules
npm install

# Create vagrant box
vagrant up

# Install project
grunt project:install

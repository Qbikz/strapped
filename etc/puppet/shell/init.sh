#!/bin/sh

# Default Puppetlabs modules
puppet module install puppetlabs-ntp
puppet module install puppetlabs-apt
puppet module install puppetlabs-mysql
puppet module install puppetlabs-nodejs

# External modules
puppet module install saz-timezone
puppet module install theforeman-git
puppet module install jfryman-nginx
puppet module install fsalum-redis
puppet module install saz-memcached
puppet module install thias-php
puppet module install fnerdwq-ssl
puppet module install torrancew-cron
puppet module install elasticsearch-elasticsearch
puppet module install maestrodev-wget
puppet module install example42-nfs
puppet module install actionjack-mailcatcher

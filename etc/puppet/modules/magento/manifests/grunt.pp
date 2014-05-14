
/**
 * [magento description]
 * @type {[type]}
 */

class magento::grunt {

    # Include NodeJS
    include ::nodejs

    # Include NPM (NodeJS has a bug for Ubuntu)
    package { $::nodejs::params::npm_pkg:
        name    => $::nodejs::params::npm_pkg,
        ensure  => present,
        require => Package[$::nodejs::params::node_pkg],
    }

    # Symlink
    file { '/usr/bin/node':
        ensure  => 'link',
        require => Package[$::nodejs::params::node_pkg],
        target  => '/usr/bin/nodejs',
    }

    # Grunt
    exec { 'grunt-cli':
        command     => 'npm install -g grunt-cli',
        path        => [ '/usr/bin', '/usr/local/bin', '/bin' ],
        timeout     => 300,
        require     => Package[$::nodejs::params::npm_pkg],
    }
}

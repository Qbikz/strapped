
/**
 * [magento description]
 * @type {[type]}
 */

class magento::tools(
    $adminer_version = '4.1.0',
) {

    # Set dependencies
    Class['nginx'] -> Class['magento::tools']
    Class['git'] -> Class['magento::tools']

    # Top
    package { [ 'htop', 'mytop', 'iotop' ]:
        ensure => present,
    }

    # Preparations
    file { [ '/var/www', '/var/www/phpinfo', '/var/www/adminer' ]:
        ensure  => directory,
        owner   => 'vagrant',
        group   => 'vagrant',
        mode    => 755,
    }

    # Install PHP info script
    file { 'phpinfo':
        ensure  => file,
        path    => '/var/www/phpinfo/index.php',
        mode    => 0644,
        owner   => 'vagrant',
        group   => 'vagrant',
        content => "<?php phpinfo();",
    }

    # Install adminer
    ::wget::fetch { 'adminer':
        source      => "http://downloads.sourceforge.net/adminer/adminer-${adminer_version}.php",
        destination => '/var/www/adminer/index.php',
        timeout     => 0,
        verbose     => false,
    }
    ::wget::fetch { 'adminer_css':
        source      => 'https://raw.github.com/vrana/adminer/master/designs/pepa-linha/adminer.css',
        destination => '/var/www/adminer/adminer.css',
        timeout     => 0,
        verbose     => false,
    }

    # PHPRedmin
    ::git::repo { 'phpredmin':
        target => '/var/www/phpredmin-repository',
        source => 'https://github.com/sasanrose/phpredmin.git',
        user   => 'vagrant',
    }
    ::cron::job { 'phpredmin':
        minute      => '*',
        hour        => '*',
        date        => '*',
        month       => '*',
        weekday     => '*',
        user        => 'vagrant',
        command     => 'cd /var/www/redis && php index.php cron/index',
        environment => [ 'MAILTO=root', 'PATH=\'/usr/bin:/bin\'' ]
    }
    file { 'phpredmin':
        path    => '/var/www/redis',
        ensure  => link,
        target  => '/var/www/phpredmin-repository/public',
        require => Git::Repo['phpredmin'],
    }

    # Memcached
    ::git::repo { 'memcachedadmin':
        target => '/var/www/memcached',
        source => 'https://github.com/hgschmie/phpmemcacheadmin.git',
        user   => 'vagrant',
    }

    # Xcache Admin
    file { 'xcache':
        path    => '/var/www/xcache',
        ensure  => link,
        target  => '/usr/share/xcache/htdocs',
        require => Package['php5-xcache'],
    }

    # Install webgrind
    ::git::repo { 'webgrind':
        target => '/var/www/webgrind',
        source => 'https://github.com/jokkedk/webgrind.git',
        user   => 'vagrant',
    }
}


/**
 * [$always_apt_update description]
 * @type {Boolean}
 */

class magento::php(
    $user       = 'vagrant',
    $group      = 'vagrant',
    $log_user   = 'vagrant',
    $log_group  = 'vagrant',
    $timezone   = 'Europe/Amsterdam',
) {

    # Symlink files to fix problems with PHP puppet module
    file { [ '/etc/php5', '/etc/php5/mods-available' ]:
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => 755,
    }
    file { '/etc/php5/conf.d':
        ensure  => link,
        owner   => 'root',
        group   => 'root',
        target  => '/etc/php5/mods-available'
    }

    # Include params
    include ::php::params

    # Require PHP CLI
    package { $::php::params::cli_package_name:
        ensure => present,
    }

    # Require PHP-FPM
    class { '::php::fpm::daemon':
        log_owner => $user,
        log_group => $group,
    }

    # Configure PHP-FPM pool
    ::php::fpm::conf { 'www':
        user                    => $user,
        group                   => $group,
        pm_max_children         => 4,
        pm_start_servers        => 2,
        pm_min_spare_servers    => 1,
        pm_max_spare_servers    => 2,
        php_admin_value         => {
            memory_limit        => '512m',
            error_reporting     => '-1',
            upload_max_filesize => '128m',
            realpath_cache_size => '16m',
        }
    }

    # PHP Modules
    ::php::module { [
        'xhprof',   'intl',     'xsl',
        'mysqlnd',  'mhash',    'mcrypt',
        'gd',       'xmlrpc',   'xcache',
        'xdebug',   'redis',    'memcached',
        'curl',
    ]: }

    # Configure Xcache PHP extension
    ::php::module::ini { 'xcache':
        settings => {
            'xcache.size'               => '64m',
            'xcache.count'              => '2',
            'xcache.var_size'           => '64m',
            'xcache.var_count'          => '2',
            'xcache.admin.enable_auth'  => 'off',
            'xcache.admin.user'         => 'admin',
            'xcache.admin.pass'         => '21232f297a57a5a743894a0e4a801fc3',
        }
    }

    # Configure Xdebug PHP extension
    ::php::module::ini { 'xdebug':
        zend        => '/usr/lib/php5/20121212',
        settings    => {
            'xdebug.default_enable'             => '0',
            'xdebug.profiler_enable_trigger'    => '1',
            'xdebug.remote_connect_back'        => '1',
        }
    }

    # Fix Mcrypt
    file { [ '/etc/php5/fpm/conf.d/20-mcrypt.ini', '/etc/php5/cli/conf.d/20-mcrypt.ini' ]:
        ensure  => link,
        owner   => 'root',
        group   => 'root',
        target  => '/etc/php5/mods-available/20-mcrypt.ini',
        require => [ Package['php5-cli'], Package['php5-fpm'], Package['php5-mcrypt'] ],
    }
}


/**
 *
 */

node default {

    # Default variables
    $timezone = 'Europe/Amsterdam'

    # Default executable paths
    Exec {
        path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/', '/usr/local/bin', '/usr/local/sbin']
    }

    # Bootstrap defaults.
    class { 'magento':
        always_apt_update   => true,
        timezone            => $timezone,
    }

    # Install Grunt
    class { 'magento::grunt': }

    # Include GIT, set default name, email.
    class { 'magento::git':,
        name    => 'Project',
        email   => 'root@project.dev',
    }

     # Bootstrap MySQL.
    class { 'magento::mysql':
        bind_address    => '0.0.0.0',
        root_password   => 'root',
        username        => 'dev',
        password_hash   => '*27AEDA0D3A56422C3F1D20DAFF0C8109058134F3',
        database        => 'project',
    }

    # Bootstrap PHP.
    class { 'magento::php':
        user        => 'vagrant',
        group       => 'vagrant',
        timezone    => $timezone,
    }

    # Create NGINX project vhost
    magento::nginx::vhost { 'project':
        server_name => "~^((?<code>.+)\\.)?$::fqdn$",
        use_cdn     => "cdn.$::fqdn",
        use_ssl     => "$::fqdn",
    }
    # Create NGINX tools vhost
    ::magento::nginx::vhost { 'tools':
        server_name => '~^(?<tool>[^\.]+)\.tools$',
        www_root    => '/var/www/$tool',
    }

    # Bootstrap ElasticSearch
    class { 'magento::elasticsearch':
        repo_version    => '1.1',
        java_install    => true,
        node_name       => 'elasticsearch01',
        autoupgrade     => true,
    }

    # Install Tools
    class { 'magento::tools': }

    # Include Snappy compression for Redis
    package { 'libsnappy1':
        ensure => present,
    }

    # Install Redis
    class { '::redis':
        system_sysctl   => true,
        conf_port       => '6379',
        conf_bind       => '0.0.0.0',
    }

    # Install Memcached
    class { '::memcached':
        max_memory  => 64,
        listen_ip   => '0.0.0.0',
        install_dev => true,
    }

    # Setup default Magento cronjob
    ::cron::job { 'magento':
        minute      => '*',
        hour        => '*',
        date        => '*',
        month       => '*',
        weekday     => '*',
        user        => 'vagrant',
        command     => 'sh /vagrant/public/cron.sh',
        environment => [ 'MAILTO=root', 'PATH=\'/usr/bin:/bin\'' ]
    }
}


/**
 * Magento
 */

class magento(
    $always_apt_update  = false,
    $timezone           = 'Europe/Amsterdam',
) {
     # Ensure enabled packages
    package { 'wget':
        ensure => present,
    }
    package { 'curl':
        ensure => present,
    }

    package { 'cachefilesd':
        ensure => present,
    }

    file { '/etc/default/cachefilesd':
        content => 'RUN=yes',
        mode    => 0644,
        owner   => 'root',
        require => Package['cachefilesd'],
    }

    # Include apt repository management
    class { '::apt':
        always_apt_update => $always_apt_update,
    }

    # Install NFS
    class { 'nfs':
        mode => 'client',
    }

    # Include NTP
    include ::ntp

    # Set default timezone
    class { '::timezone':
        timezone    => $timezone,
        autoupgrade => true,
    }

    # Execute package upgrades
    exec { 'apt-get -y dist-upgrade':
        refreshonly => true,
        path        => ['/usr/bin', '/bin'],
        timeout     => 3600,
    }
}

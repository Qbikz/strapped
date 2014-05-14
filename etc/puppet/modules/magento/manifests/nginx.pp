
/**
 * [magento description]
 * @type {[type]}
 */

class magento::nginx {
    # Set custom FastCGI params
    if !defined(File['/etc/nginx/fastcgi_params']) {
        file { '/etc/nginx/fastcgi_params':
            ensure  => present,
            mode    => '0770',
            content => template('magento/vhost/fastcgi_params.erb'),
        }
    }

    # Include Nginx
    class { '::nginx':
        manage_repo => false,
    }
}

/**
 * [magento description]
 * @type {[type]}
 */

define magento::nginx::vhost::create(
    $server_name,
    $use_ssl        = false,
    $use_fastcgi    = true,
    $www_root       = '/vagrant/public',
    $listen_port    = 80,
) {

    # Make boolean
    if $use_ssl {
        $ssl = true
    } else {
        $ssl = false
    }

    # Create default VHOST
    ::nginx::resource::vhost { "${name}":
        ensure                  => present,
        server_name             => [ $server_name ],
        index_files             => [ 'index.php' ],
        www_root                => $www_root,
        use_default_location    => false,
        client_max_body_size    => '128m',
        access_log              => "/var/log/nginx/${name}.access.log",
        error_log               => "/var/log/nginx/${name}.error.log",
    }

    # Check whether to generate SSL certificates
    if $use_ssl {
        ::ssl::self_signed_certificate { "${name}":
            common_name         => $use_ssl,
            email_address       => "root@${use_ssl}",
            country             => 'NL',
            state               => 'ZH',
            organization        => 'Project',
            locality            => 'Rotterdam',
            unit                => 'Development',
            days                => 730,
            subject_alt_name    => "DNS:*.${use_ssl}, DNS:${use_ssl}",
        }
        # Edit vhost, set ports
        Nginx::Resource::Vhost["${name}"] {
            listen_port     => 443,
            ssl             => true,
            ssl_cert        => "/etc/ssl/${name}.crt",
            ssl_key         => "/etc/ssl/${name}.key",
        }
    }

    # Default location for vhost
    ::nginx::resource::location { "${name}-default":
        ensure          => present,
        vhost           => $name,
        ssl             => $ssl,
        ssl_only        => $ssl,
        location        => '/',
        www_root        => $www_root,
        try_files       => [ '$uri', '$uri/', '@handler' ],
    }

    # Handler location for vhost
    ::nginx::resource::location { "${name}-handler":
        ensure          => present,
        vhost           => $name,
        ssl             => $ssl,
        ssl_only        => $ssl,
        location        => '@handler',
        www_root        => $www_root,
        rewrite_rules   => [ '/ /index.php' ],
    }

    # PHP support
    if $use_fastcgi {
        # Create location for @handler
        ::nginx::resource::location { "${name}-fastcgi":
            ensure              => present,
            vhost               => $name,
            ssl                 => $ssl,
            ssl_only            => $ssl,
            location            => '~ \.php$',
            fastcgi             => '127.0.0.1:9000',
            fastcgi_split_path  => '^(.+\.php)(/.+)$',
        }
    }
}

/**
 * Define to create a NGINX vhosts for a specified server name.
 */

define magento::nginx::vhost(
    $server_name,
    $www_root   = '/vagrant/public',
    $use_ssl    = false,
    $use_cdn    = false,
) {
    # Include NGINX
    include ::magento::nginx

    # Create default vhost
    ::magento::nginx::vhost::create { "${name}-nossl":
        server_name => $server_name,
        www_root    => $www_root,
    }
    if $use_ssl {
        ::magento::nginx::vhost::create { "${name}-ssl":
            server_name => $server_name,
            www_root    => $www_root,
            use_ssl     => $use_ssl,
        }
    }

    # Whether to create a default CDN domain
    if $use_cdn {
        ::magento::nginx::vhost::create { "${name}-cdn-nossl":
            server_name => $use_cdn,
            www_root    => $www_root,
        }
        if $use_ssl {
            ::magento::nginx::vhost::create { "${name}-cdn-ssl":
                server_name => $use_cdn,
                www_root    => $www_root,
                use_ssl     => $use_ssl,
            }
        }
    }
}


/**
 * Copied from puppetlabs-git.
 */
define magento::git::config($value) {

    # Extract section and key with regex
    $section= regsubst($name, '^([^\.]+)\.([^\.]+)$','\1')
    $key    = regsubst($name, '^([^\.]+)\.([^\.]+)$','\2')

    # Execute configuration
    exec { "git.config.set.${section}.${key}":
        command     => "git config --global ${section}.${key} '${value}'",
        environment => inline_template('<%= "HOME=" + ENV["HOME"] %>'),
        path        => ['/usr/bin', '/bin'],
        unless      => "git config --global --get ${section}.${key} '${value}'",
        require     => Package['git'],
    }
}

/**
 *
 */

class magento::git(
    $name   = 'Project',
    $email  = 'root@project.dev',
) {
    # Include GIT package
    include ::git

    # Configure defaults for GIT
    ::magento::git::config { 'user.name':
        value => $name,
    }
    ::magento::git::config { 'user.email':
        value => $email,
    }
}

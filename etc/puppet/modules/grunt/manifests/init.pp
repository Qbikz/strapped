
class grunt {
    # Include params
    include grunt::params

    # Ensure presence of global Grunt
    package { $grunt::params::pkg_name:
        ensure: latest,
        provider: 'npm'
    }
}

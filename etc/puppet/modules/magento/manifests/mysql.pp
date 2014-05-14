
/**
 * [$always_apt_update description]
 * @type {Boolean}
 */

class magento::mysql(
    $root_password  = 'root',
    $username       = 'user',
    $password_hash  = '',
    $database       = 'database',
    $bind_address   = '127.0.0.1',
    $optimize       = true,
) {
    # Include MySQL tuner to examine stability
    class { '::mysql::server::mysqltuner': }

    # Install MySQL client for CLI interface
    class { '::mysql::client': }

    # Install MySQL server
    class { '::mysql::server':
        restart             => true,
        root_password       => $root_password,
        override_options    => {
            'mysqld' => {
                'max_connections'                   => '1024',
                'bind_address'                      => $bind_address,
                'key_buffer_size'                   => '64M',
                'max_allowed_packet'                => '64M',
                'query_cache_type'                  => '1',
                'query_cache_size'                  => '128M',
                'query_cache_limit'                 => '1M',
                'innodb'                            => 'FORCE',
                'innodb_lock_wait_timeout'          => '300',
                'innodb_flush_method'               => 'O_DIRECT',
                #'innodb_log_files_in_group'         => '2',
                #'innodb_log_file_size'              => '512M',
                #'innodb_log_block_size'             => '4096',
                #'innodb_flush_log_at_trx_commit'    => '2',
                'innodb_file_per_table'             => '1',
                'innodb_buffer_pool_size'           => '1G',
                'innodb_buffer_pool_instances'      => '1',
                'innodb_read_io_threads'            => '2',
                'innodb_write_io_threads'           => '2',
                #'innodb_doublewrite'                => '0',
                #'innodb_io_capacity'                => '4096',
                #'innodb_flush_neighbors'            => '0',
                #'innodb_max_dirty_pages_pct'        => '60',
            },
        },
        users => {
            "${username}@%" => {
                ensure                      => 'present',
                max_connections_per_hour    => '0',
                max_queries_per_hour        => '0',
                max_updates_per_hour        => '0',
                max_user_connections        => '0',
                password_hash               => $password_hash,
            },
        },
        grants => {
            "${username}@%/*.*" => {
                ensure      => 'present',
                options     => ['GRANT'],
                privileges  => ['ALL'],
                table       => '*.*',
                user        => "${username}@%",
            },
        },
        databases => {
            "${database}" => {
                ensure  => 'present',
                charset => 'utf8',
            },
        }
    }
}


/**
 * [magento description]
 * @type {[type]}
 */

class magento::elasticsearch(
    $repo_version   = '1.1',
    $java_install   = true,
    $node_name      = 'elasticsearch01',
    $autoupgrade    = true,
) {

    # Install elasticsearch
    class { '::elasticsearch':
        version         => $version,
        autoupgrade     => $autoupgrade,
        java_install    => $java_install,
        manage_repo     => true,
        repo_version    => $repo_version,
        config          => {
            'node' => {
                'name' => $node_name,
            },
            'index' => {
                'number_of_replicas' => '1',
                'number_of_shards'   => '5',
            }
        }
    }

    # Install plugins
    ::elasticsearch::plugin { 'mobz/elasticsearch-head':
        module_dir => 'head'
    }
}

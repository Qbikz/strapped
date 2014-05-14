# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # VM configuration
  config.vm.hostname  = "project.dev"
  config.vm.box       = "puppetlabs/ubuntu-14.04-64-puppet"

  # Network configuration
  config.vm.network "private_network", ip: "10.0.100.100"

  # Setup NFS
  config.vm.synced_folder '.', '/vagrant', nfs: true, mount_options: ['rw', 'vers=4', 'tcp', 'fsc']

  # Virtualbox configuration
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Default provision with shell script
  config.vm.provision :shell, :path => "etc/puppet/shell/init.sh"

  # Provision with Puppet
  config.vm.provision :puppet do |puppet|
    # change fqdn to give to change the vm virtual host
    puppet.facter = {
      "fqdn"      => config.vm.hostname,
      "hostname"  => "project",
      "docroot"   => "/vagrant",
    }

    # set the puppet manifests directory
    puppet.manifests_path = "etc/puppet/manifests"
    puppet.manifest_file  = "main.pp"
    puppet.module_path    = "etc/puppet/modules"
  end

  # After provision with shell script
  config.vm.provision :shell, :path => "etc/puppet/shell/after.sh"
end

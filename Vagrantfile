# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

$box = 'coderwall'
$box_url = 'http://cdn.coderwall.com/vagrant/coderwall.box'
$provision = 'vagrant/bootstrap.sh'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = $box
  config.vm.box_url = $box_url
  config.vm.provision :shell do |s|
    s.path = $provision
  end

  config.ssh.keep_alive = true
  config.ssh.forward_agent = true

  config.vm.network :private_network, ip: '192.168.237.95' # 192.168.cdr.wl

  # Postgres
  config.vm.network :forwarded_port, guest: 5432, host: 2200
  # Redis
  config.vm.network :forwarded_port, guest: 6379, host: 2201
  # ElasticSearch
  config.vm.network :forwarded_port, guest: 9200, host: 9200
  # MongoDB
  config.vm.network :forwarded_port, guest: 27017, host: 27017

  config.vm.synced_folder '.', '/home/vagrant/web', nfs: true

  config.vm.provider :virtualbox do |vb|
    vb.customize ['modifyvm', :id, '--cpus', '4']
    vb.customize ['modifyvm', :id, '--ioapic', 'on']
    vb.customize ['modifyvm', :id, '--memory', '4096']

    # https://github.com/mitchellh/vagrant/issues/1807
    # whatupdave: my VM was super slow until I added these:
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    # seems to be safe to run: https://github.com/griff/docker/commit/e5239b98598ece4287c1088e95a2eaed585d2da4
  end

  config.vbguest.auto_update = true
  config.vbguest.no_remote = false
end

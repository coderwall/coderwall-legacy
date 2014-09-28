# -*- mode: ruby -*-
# vi: set ft=ruby :

# Load in custom vagrant settings
raise <<-EOF unless File.exists?("vagrant.yml")

  Hi! Before getting started with Vagrant and Coderwall
  you'll need to setup the `vagrant.yml`. There should
  be a file `vagrant.yml.example` that you can use as
  a base reference. Copy the `vagrant.yml.example` to
  `vagrant.yml` to get started.

EOF

require 'yaml'
custom_settings = File.file?('vagrant.yml') ?  YAML.load_file('vagrant.yml') : {}

puts '== Using Custom Vagrant Settings =='
puts custom_settings.inspect

VAGRANTFILE_API_VERSION = "2"

$box = 'coderwall_v2'
$box_url = 'https://s3.amazonaws.com/coderwall-assets-0/vagrant/coderwall_v2.box' # The box is 1.4GB.
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

  set_port_mapping_for(config, 'elasticsearch', 9200,  custom_settings)
  set_port_mapping_for(config, 'mongodb',       27017, custom_settings)
  set_port_mapping_for(config, 'postgres',      5432,  custom_settings)
  set_port_mapping_for(config, 'redis',         6379,  custom_settings)
  set_port_mapping_for(config, 'rails',         3000,  custom_settings, true)

  config.vm.synced_folder '.', '/home/vagrant/web', nfs: custom_settings['use_nfs']

  config.vm.provider :virtualbox do |vb|
    # Use custom settings unless they don't exist
    if virtualbox_settings = custom_settings['virtualbox']
      vb.customize ['modifyvm', :id, '--cpus',   "#{virtualbox_settings['cpus']   || 2}"]
      vb.customize ['modifyvm', :id, '--memory', "#{virtualbox_settings['memory'] || 2048}"]
    else
      vb.customize ['modifyvm', :id, '--cpus',   '2']
      vb.customize ['modifyvm', :id, '--memory', '2048']
    end

    vb.customize ['modifyvm', :id, '--ioapic', 'on']

    # https://github.com/mitchellh/vagrant/issues/1807
    # whatupdave: my VM was super slow until I added these:
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    # seems to be safe to run: https://github.com/griff/docker/commit/e5239b98598ece4287c1088e95a2eaed585d2da4
  end

  if Vagrant.has_plugin?('vagrant-vbguest')
    config.vbguest.auto_update = true
    config.vbguest.no_remote = false
  else
    puts "Please install the 'vagrant-vbguest' plugin"
  end
end

def set_port_mapping_for(config, service, guest_port, settings, force = false)
  if settings['network'] && settings['network']['port_mappings'] && settings['network']['port_mappings'][service]
    host_port = settings['network']['port_mappings'][service]
    puts " !! Setting up port mapping rule for #{service} host:#{host_port} => guest:#{guest_port}"
    config.vm.network(:forwarded_port, guest: guest_port,  host: host_port)
  else
    # no host port mapping was defined
    if force
      # but we want to force a mapping for the default ports
      puts " !! Setting up port mapping rule for #{service} host:#{guest_port} => guest:#{guest_port}"
      config.vm.network(:forwarded_port, guest: guest_port,  host: guest_port)
    end
  end
end

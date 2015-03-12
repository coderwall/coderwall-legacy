#
# Cookbook Name:: postgresql
# Recipe:: config_version
#
# Defines version-sensitive default attributes after all other attributes files
# have been evaluated, allowing users of this cookbook to use default
# attributes in attribute files to set the postgresql version and still have
# sensible defaults for everything.
#
# To override any attribute defined in this recipe using an attribute file,
# you must use force_default or higher. See
# https://docs.getchef.com/essentials_cookbook_attribute_files.html for info.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform']
when "debian"

  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when node['platform_version'].to_f < 6.0 # All 5.X
    node.default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    node.default['postgresql']['server']['service_name'] = "postgresql"
  end

  node.default['postgresql']['client']['packages'] = ["postgresql-client-#{node['postgresql']['version']}","libpq-dev"]
  node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']}"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql-contrib-#{node['postgresql']['version']}"]

when "ubuntu"

  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  case
  when (node['platform_version'].to_f <= 10.04) && (! node['postgresql']['enable_pgdg_apt'])
    node.default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    node.default['postgresql']['server']['service_name'] = "postgresql"
  end

  node.default['postgresql']['client']['packages'] = ["postgresql-client-#{node['postgresql']['version']}","libpq-dev"]
  node.default['postgresql']['server']['packages'] = ["postgresql-#{node['postgresql']['version']}"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql-contrib-#{node['postgresql']['version']}"]

when "fedora"

  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
  node.default['postgresql']['server']['packages'] = %w{postgresql-server}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  node.default['postgresql']['server']['service_name'] = "postgresql"

when "amazon"

  if node['platform_version'].to_f >= 2012.03
    node.default['postgresql']['version'] = "9.0"
    node.default['postgresql']['dir'] = "/var/lib/pgsql9/data"
  else
    node.default['postgresql']['version'] = "8.4"
    node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  end

  node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
  node.default['postgresql']['server']['packages'] = %w{postgresql-server}
  node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  node.default['postgresql']['server']['service_name'] = "postgresql"

when "redhat", "centos", "scientific", "oracle"

  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"

  if node['platform_version'].to_f >= 6.0 && node['postgresql']['version'] == '8.4'
    node.default['postgresql']['client']['packages'] = %w{postgresql-devel}
    node.default['postgresql']['server']['packages'] = %w{postgresql-server}
    node.default['postgresql']['contrib']['packages'] = %w{postgresql-contrib}
  else
    node.default['postgresql']['client']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-devel"]
    node.default['postgresql']['server']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-server"]
    node.default['postgresql']['contrib']['packages'] = ["postgresql#{node['postgresql']['version'].split('.').join}-contrib"]
  end

  if node['platform_version'].to_f >= 6.0 && node['postgresql']['version'] != '8.4'
     node.default['postgresql']['dir'] = "/var/lib/pgsql/#{node['postgresql']['version']}/data"
     node.default['postgresql']['server']['service_name'] = "postgresql-#{node['postgresql']['version']}"
  else
    node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
    node.default['postgresql']['server']['service_name'] = "postgresql"
  end

when "suse"

  if node['postgresql']['version'] = '8.3'
    node.default['postgresql']['client']['packages'] = ['postgresql', 'rubygem-pg']
    node.default['postgresql']['server']['packages'] = ['postgresql-server']
    node.default['postgresql']['contrib']['packages'] = ['postgresql-contrib']
  elsif node['postgresql']['version'] == '9.1'
    node.default['postgresql']['client']['packages'] = ['postgresql91', 'rubygem-pg']
    node.default['postgresql']['server']['packages'] = ['postgresql91-server']
    node.default['postgresql']['contrib']['packages'] = ['postgresql91-contrib']
  end

  node.default['postgresql']['dir'] = "/var/lib/pgsql/data"
  node.default['postgresql']['server']['service_name'] = "postgresql"

else
  node.default['postgresql']['dir'] = "/etc/postgresql/#{node['postgresql']['version']}/main"
  node.default['postgresql']['client']['packages'] = ["postgresql"]
  node.default['postgresql']['server']['packages'] = ["postgresql"]
  node.default['postgresql']['contrib']['packages'] = ["postgresql"]
  node.default['postgresql']['server']['service_name'] = "postgresql"
end

case node[:platform_family]
when 'debian'
  node.default['postgresql']['config']['data_directory'] = "/var/lib/postgresql/#{node['postgresql']['version']}/main"
  node.default['postgresql']['config']['hba_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_hba.conf"
  node.default['postgresql']['config']['ident_file'] = "/etc/postgresql/#{node['postgresql']['version']}/main/pg_ident.conf"
  node.default['postgresql']['config']['external_pid_file'] = "/var/run/postgresql/#{node['postgresql']['version']}-main.pid"
  node.default['postgresql']['config']['unix_socket_directory'] = '/var/run/postgresql' if node['postgresql']['version'].to_f < 9.3
  node.default['postgresql']['config']['unix_socket_directories'] = '/var/run/postgresql' if node['postgresql']['version'].to_f >= 9.3
  node.default['postgresql']['config']['max_fsm_pages'] = 153600 if node['postgresql']['version'].to_f < 8.4
  node.default['postgresql']['config']['ssl_cert_file'] = '/etc/ssl/certs/ssl-cert-snakeoil.pem' if node['postgresql']['version'].to_f >= 9.2
  node.default['postgresql']['config']['ssl_key_file'] = '/etc/ssl/private/ssl-cert-snakeoil.key'if node['postgresql']['version'].to_f >= 9.2
end

if not %w(squeeze wheezy sid lucid precise saucy trusty utopic).include? node['postgresql']['pgdg']['release_apt_codename']
  raise "Not supported release by PGDG apt repository"
end

include_recipe 'postgresql::config_version'
include_recipe 'apt'

file "remove deprecated Pitti PPA apt repository" do
  action :delete
  path "/etc/apt/sources.list.d/pitti-postgresql-ppa"
end

apt_repository 'apt.postgresql.org' do
  uri 'http://apt.postgresql.org/pub/repos/apt'
  distribution "#{node['postgresql']['pgdg']['release_apt_codename']}-pgdg"
  components ['main', node['postgresql']['version']]
  key 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'
  action :add
end

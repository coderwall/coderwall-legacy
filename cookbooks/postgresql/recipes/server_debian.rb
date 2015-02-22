#
# Cookbook Name:: postgresql
# Recipe:: server
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

include_recipe 'postgresql::config_version'
include_recipe "postgresql::client"

node['postgresql']['server']['packages'].each do |pg_pack|

  package pg_pack

end

include_recipe "postgresql::server_conf"

service "postgresql" do
  service_name node['postgresql']['server']['service_name']
  supports :restart => true, :status => true, :reload => true
  action [:enable, :start]
end

execute 'Set locale and Create cluster' do
  command 'export LC_ALL=C; /usr/bin/pg_createcluster --start ' + node['postgresql']['version'] + ' main'
  action :run
  not_if { ::File.directory?('/etc/postgresql/' + node['postgresql']['version'] + '/main') }
end
